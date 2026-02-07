#!/usr/bin/env bash
#
# wp-rest.sh — WordPress REST API helper for the wp-publish skill
# Version: 1.0.0
#
# Usage: wp-rest.sh <command> [args...] [--site=NAME]
#
# Auth: Uses ~/clawd/.wp-sites.json with curl -K (credentials never in process args)
#

set -euo pipefail

CONFIG_FILE="${HOME}/clawd/.wp-sites.json"

# ─── Auth ────────────────────────────────────────────────────────────────────

setup_auth() {
    local site_arg="${1:-}"

    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Error: $CONFIG_FILE not found" >&2
        echo "Run wp-publish to add a site first." >&2
        exit 1
    fi

    local SITE
    if [ -n "$site_arg" ]; then
        SITE="$site_arg"
    else
        SITE=$(jq -r '.default // empty' "$CONFIG_FILE")
    fi

    [ -z "$SITE" ] && { echo "Error: no site specified and no default set in $CONFIG_FILE" >&2; exit 1; }

    WP_SITE_URL=$(jq -r ".sites[\"$SITE\"].url // empty" "$CONFIG_FILE")
    [ -z "$WP_SITE_URL" ] && { echo "Error: site '$SITE' not found in $CONFIG_FILE" >&2; exit 1; }

    WP_AUTH_FILE=$(umask 077; mktemp /tmp/wp-auth-XXXXXX)
    trap 'rm -f "$WP_AUTH_FILE"' EXIT

    jq -r ".sites[\"$SITE\"] | \"--user \" + .username + \":\" + .app_password" \
        "$CONFIG_FILE" > "$WP_AUTH_FILE"

    CURRENT_SITE="$SITE"
}

wp_curl() {
    curl -s -K "$WP_AUTH_FILE" "$@"
}

# ─── Helpers ─────────────────────────────────────────────────────────────────

json_extract() {
    # Extract a field from JSON, usage: echo '{}' | json_extract .field
    jq -r "$1" 2>/dev/null
}

require_id() {
    if [ -z "${1:-}" ]; then
        echo "Error: ID required" >&2
        exit 1
    fi
}

require_file() {
    if [ ! -f "${1:-}" ]; then
        echo "Error: file not found: ${1:-}" >&2
        exit 1
    fi
}

# ─── Markdown to Gutenberg ───────────────────────────────────────────────────

markdown_to_gutenberg() {
    local input="${1:--}"  # file path or - for stdin
    local content

    if [ "$input" = "-" ]; then
        content=$(cat)
    else
        require_file "$input"
        content=$(cat "$input")
    fi

    echo "$content" | awk '
    BEGIN { in_list = 0; in_ol = 0; in_code = 0; code_lang = "" }

    # Fenced code blocks
    /^```/ {
        if (in_code) {
            printf "</code></pre>\n<!-- /wp:code -->\n"
            in_code = 0
            next
        } else {
            close_list()
            code_lang = substr($0, 4)
            if (code_lang != "") {
                printf "<!-- wp:code -->\n<pre class=\"wp-block-code\"><code class=\"language-%s\">", code_lang
            } else {
                printf "<!-- wp:code -->\n<pre class=\"wp-block-code\"><code>"
            }
            in_code = 1
            next
        }
    }

    in_code {
        gsub(/&/, "\\&amp;")
        gsub(/</, "\\&lt;")
        gsub(/>/, "\\&gt;")
        print
        next
    }

    # Blank lines close lists
    /^[[:space:]]*$/ {
        close_list()
        next
    }

    # Headings
    /^######[[:space:]]/ { close_list(); h = substr($0, 8); printf "<!-- wp:heading {\"level\":6} -->\n<h6 class=\"wp-block-heading\">%s</h6>\n<!-- /wp:heading -->\n", h; next }
    /^#####[[:space:]]/ { close_list(); h = substr($0, 7); printf "<!-- wp:heading {\"level\":5} -->\n<h5 class=\"wp-block-heading\">%s</h5>\n<!-- /wp:heading -->\n", h; next }
    /^####[[:space:]]/ { close_list(); h = substr($0, 6); printf "<!-- wp:heading {\"level\":4} -->\n<h4 class=\"wp-block-heading\">%s</h4>\n<!-- /wp:heading -->\n", h; next }
    /^###[[:space:]]/ { close_list(); h = substr($0, 5); printf "<!-- wp:heading {\"level\":3} -->\n<h3 class=\"wp-block-heading\">%s</h3>\n<!-- /wp:heading -->\n", h; next }
    /^##[[:space:]]/ { close_list(); h = substr($0, 4); printf "<!-- wp:heading {\"level\":2} -->\n<h2 class=\"wp-block-heading\">%s</h2>\n<!-- /wp:heading -->\n", h; next }
    /^#[[:space:]]/ { close_list(); h = substr($0, 3); printf "<!-- wp:heading {\"level\":1} -->\n<h1 class=\"wp-block-heading\">%s</h1>\n<!-- /wp:heading -->\n", h; next }

    # Horizontal rule
    /^(---|___|\*\*\*)[[:space:]]*$/ {
        close_list()
        printf "<!-- wp:separator -->\n<hr class=\"wp-block-separator has-alpha-channel-opacity\"/>\n<!-- /wp:separator -->\n"
        next
    }

    # Blockquote
    /^>[[:space:]]/ {
        close_list()
        q = substr($0, 3)
        printf "<!-- wp:quote -->\n<blockquote class=\"wp-block-quote\"><p>%s</p></blockquote>\n<!-- /wp:quote -->\n", q
        next
    }

    # Unordered list items
    /^[[:space:]]*[-*+][[:space:]]/ {
        if (!in_list) {
            printf "<!-- wp:list -->\n<ul class=\"wp-block-list\">\n"
            in_list = 1
        }
        sub(/^[[:space:]]*[-*+][[:space:]]/, "")
        printf "<li>%s</li>\n", inline_format($0)
        next
    }

    # Ordered list items
    /^[[:space:]]*[0-9]+\.[[:space:]]/ {
        if (!in_ol) {
            printf "<!-- wp:list {\"ordered\":true} -->\n<ol class=\"wp-block-list\">\n"
            in_ol = 1
        }
        sub(/^[[:space:]]*[0-9]+\.[[:space:]]/, "")
        printf "<li>%s</li>\n", inline_format($0)
        next
    }

    # Image: ![alt](url)
    /^!\[.*\]\(.*\)/ {
        close_list()
        alt = $0; sub(/^!\[/, "", alt); sub(/\].*/, "", alt)
        url = $0; sub(/.*\]\(/, "", url); sub(/\).*/, "", url)
        printf "<!-- wp:image -->\n<figure class=\"wp-block-image\"><img src=\"%s\" alt=\"%s\"/></figure>\n<!-- /wp:image -->\n", url, alt
        next
    }

    # Regular paragraph
    {
        close_list()
        printf "<!-- wp:paragraph -->\n<p>%s</p>\n<!-- /wp:paragraph -->\n", inline_format($0)
    }

    function close_list() {
        if (in_list) {
            printf "</ul>\n<!-- /wp:list -->\n"
            in_list = 0
        }
        if (in_ol) {
            printf "</ol>\n<!-- /wp:list -->\n"
            in_ol = 0
        }
    }

    function inline_format(text) {
        # Bold: **text** or __text__
        while (match(text, /\*\*[^*]+\*\*/)) {
            pre = substr(text, 1, RSTART-1)
            mid = substr(text, RSTART+2, RLENGTH-4)
            post = substr(text, RSTART+RLENGTH)
            text = pre "<strong>" mid "</strong>" post
        }
        # Italic: *text* or _text_
        while (match(text, /\*[^*]+\*/)) {
            pre = substr(text, 1, RSTART-1)
            mid = substr(text, RSTART+1, RLENGTH-2)
            post = substr(text, RSTART+RLENGTH)
            text = pre "<em>" mid "</em>" post
        }
        # Inline code: `text`
        while (match(text, /`[^`]+`/)) {
            pre = substr(text, 1, RSTART-1)
            mid = substr(text, RSTART+1, RLENGTH-2)
            post = substr(text, RSTART+RLENGTH)
            text = pre "<code>" mid "</code>" post
        }
        # Links: [text](url)
        while (match(text, /\[[^\]]+\]\([^)]+\)/)) {
            pre = substr(text, 1, RSTART-1)
            chunk = substr(text, RSTART, RLENGTH)
            post = substr(text, RSTART+RLENGTH)
            ltxt = chunk; sub(/^\[/, "", ltxt); sub(/\].*/, "", ltxt)
            lurl = chunk; sub(/.*\]\(/, "", lurl); sub(/\)$/, "", lurl)
            text = pre "<a href=\"" lurl "\">" ltxt "</a>" post
        }
        return text
    }

    END { close_list() }
    '
}

# ─── Content Health Check ────────────────────────────────────────────────────

content_health_check() {
    local post_id="$1"
    require_id "$post_id"

    local post
    post=$(wp_curl "${WP_SITE_URL}/wp-json/wp/v2/posts/${post_id}?context=edit")

    local title content excerpt slug
    title=$(echo "$post" | jq -r '.title.raw // .title.rendered // ""')
    content=$(echo "$post" | jq -r '.content.raw // .content.rendered // ""')
    excerpt=$(echo "$post" | jq -r '.excerpt.raw // .excerpt.rendered // ""')
    slug=$(echo "$post" | jq -r '.slug // ""')
    local featured_media
    featured_media=$(echo "$post" | jq -r '.featured_media // 0')
    local categories tags
    categories=$(echo "$post" | jq -r '.categories | length')
    tags=$(echo "$post" | jq -r '.tags | length')

    local score=0
    local max_score=100
    local issues=()
    local passes=()

    # Title checks (20 points)
    local title_len=${#title}
    if [ "$title_len" -ge 10 ] && [ "$title_len" -le 70 ]; then
        score=$((score + 20))
        passes+=("Title length OK ($title_len chars)")
    elif [ "$title_len" -gt 0 ]; then
        score=$((score + 10))
        issues+=("Title length: $title_len chars (ideal: 10-70)")
    else
        issues+=("Missing title")
    fi

    # Content length (20 points)
    local content_text
    content_text=$(echo "$content" | sed 's/<[^>]*>//g' | tr -s '[:space:]')
    local word_count
    word_count=$(echo "$content_text" | wc -w | tr -d ' ')
    if [ "$word_count" -ge 300 ]; then
        score=$((score + 20))
        passes+=("Word count: $word_count (good)")
    elif [ "$word_count" -ge 100 ]; then
        score=$((score + 10))
        issues+=("Word count: $word_count (aim for 300+)")
    else
        issues+=("Word count: $word_count (too short, aim for 300+)")
    fi

    # Excerpt (10 points)
    local excerpt_text
    excerpt_text=$(echo "$excerpt" | sed 's/<[^>]*>//g' | tr -s '[:space:]')
    if [ ${#excerpt_text} -ge 10 ]; then
        score=$((score + 10))
        passes+=("Has excerpt")
    else
        issues+=("Missing or short excerpt")
    fi

    # Featured image (15 points)
    if [ "$featured_media" -gt 0 ]; then
        score=$((score + 15))
        passes+=("Has featured image")
    else
        issues+=("No featured image")
    fi

    # Categories (10 points)
    if [ "$categories" -gt 0 ]; then
        score=$((score + 10))
        passes+=("Categorized ($categories)")
    else
        issues+=("No categories assigned")
    fi

    # Tags (5 points)
    if [ "$tags" -gt 0 ]; then
        score=$((score + 5))
        passes+=("Tagged ($tags)")
    else
        issues+=("No tags assigned")
    fi

    # Headings in content (10 points)
    local heading_count
    heading_count=$(echo "$content" | grep -c '<h[2-4]' || true)
    if [ "$heading_count" -ge 2 ]; then
        score=$((score + 10))
        passes+=("Has $heading_count subheadings")
    elif [ "$heading_count" -ge 1 ]; then
        score=$((score + 5))
        issues+=("Only $heading_count subheading (aim for 2+)")
    else
        issues+=("No subheadings (add H2/H3 for readability)")
    fi

    # Internal/external links (5 points)
    local link_count
    link_count=$(echo "$content" | grep -oP '<a[^>]+href=' | wc -l | tr -d ' ')
    if [ "$link_count" -ge 1 ]; then
        score=$((score + 5))
        passes+=("Has $link_count links")
    else
        issues+=("No links (add internal/external links)")
    fi

    # Images in content (5 points)
    local img_count
    img_count=$(echo "$content" | grep -c '<img' || true)
    if [ "$img_count" -ge 1 ]; then
        score=$((score + 5))
        passes+=("Has $img_count images in content")
    else
        issues+=("No images in content body")
    fi

    # Output report
    echo "=== Content Health Check: Post #${post_id} ==="
    echo "Title: $title"
    echo "Slug: $slug"
    echo "Words: $word_count"
    echo ""

    local grade
    if [ "$score" -ge 90 ]; then grade="A"
    elif [ "$score" -ge 80 ]; then grade="B"
    elif [ "$score" -ge 70 ]; then grade="C"
    elif [ "$score" -ge 60 ]; then grade="D"
    else grade="F"
    fi

    echo "Score: ${score}/${max_score} (${grade})"
    echo ""

    if [ ${#passes[@]} -gt 0 ]; then
        echo "PASS:"
        for p in "${passes[@]}"; do echo "  + $p"; done
    fi

    if [ ${#issues[@]} -gt 0 ]; then
        echo ""
        echo "ISSUES:"
        for i in "${issues[@]}"; do echo "  - $i"; done
    fi
}

# ─── Posts ───────────────────────────────────────────────────────────────────

cmd_list_posts() {
    local per_page="${1:-10}"
    local status="${2:-any}"
    wp_curl "${WP_SITE_URL}/wp-json/wp/v2/posts?per_page=${per_page}&status=${status}&orderby=date&order=desc" \
        | jq '.[] | {id, title: .title.rendered, status, date, link}'
}

cmd_get_post() {
    require_id "$1"
    wp_curl "${WP_SITE_URL}/wp-json/wp/v2/posts/${1}?context=edit" \
        | jq '{id, title: .title.raw, status, date, modified, slug, link, excerpt: .excerpt.raw, categories, tags, featured_media}'
}

cmd_search_posts() {
    local query="${1:?Search query required}"
    wp_curl "${WP_SITE_URL}/wp-json/wp/v2/posts?search=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$query'))")&per_page=20" \
        | jq '.[] | {id, title: .title.rendered, status, date, link}'
}

cmd_create_post() {
    local json_file="${1:?JSON file path required}"
    require_file "$json_file"
    wp_curl -X POST "${WP_SITE_URL}/wp-json/wp/v2/posts" \
        -H "Content-Type: application/json" \
        -d @"$json_file" | jq '{id, title: .title.rendered, status, link}'
}

cmd_create_post_markdown() {
    local md_file="${1:?Markdown file path required}"
    local title="${2:-}"
    local status="${3:-draft}"
    require_file "$md_file"

    # Extract title from first H1 if not provided
    if [ -z "$title" ]; then
        title=$(head -5 "$md_file" | grep '^# ' | head -1 | sed 's/^# //')
    fi
    [ -z "$title" ] && title=$(basename "$md_file" .md)

    local gutenberg_content
    gutenberg_content=$(markdown_to_gutenberg "$md_file")

    local tmpjson
    tmpjson=$(mktemp /tmp/wp-post-XXXXXX.json)
    jq -n --arg title "$title" \
          --arg content "$gutenberg_content" \
          --arg status "$status" \
          '{title: $title, content: $content, status: $status}' > "$tmpjson"

    wp_curl -X POST "${WP_SITE_URL}/wp-json/wp/v2/posts" \
        -H "Content-Type: application/json" \
        -d @"$tmpjson" | jq '{id, title: .title.rendered, status, link}'

    rm -f "$tmpjson"
}

cmd_update_post() {
    local post_id="${1:?Post ID required}"
    local json_file="${2:?JSON file path required}"
    require_file "$json_file"
    wp_curl -X POST "${WP_SITE_URL}/wp-json/wp/v2/posts/${post_id}" \
        -H "Content-Type: application/json" \
        -d @"$json_file" | jq '{id, title: .title.rendered, status, link}'
}

cmd_delete_post() {
    local post_id="${1:?Post ID required}"
    local force="${2:-false}"
    if [ "$force" = "true" ]; then
        wp_curl -X DELETE "${WP_SITE_URL}/wp-json/wp/v2/posts/${post_id}?force=true" | jq '{id, deleted: true}'
    else
        wp_curl -X DELETE "${WP_SITE_URL}/wp-json/wp/v2/posts/${post_id}" | jq '{id, status}'
    fi
}

cmd_publish_post() {
    local post_id="${1:?Post ID required}"
    wp_curl -X POST "${WP_SITE_URL}/wp-json/wp/v2/posts/${post_id}" \
        -H "Content-Type: application/json" \
        -d '{"status":"publish"}' | jq '{id, title: .title.rendered, status, link}'
}

cmd_schedule_post() {
    local post_id="${1:?Post ID required}"
    local datetime="${2:?Date required (YYYY-MM-DDTHH:MM:SS)}"
    wp_curl -X POST "${WP_SITE_URL}/wp-json/wp/v2/posts/${post_id}" \
        -H "Content-Type: application/json" \
        -d "{\"status\":\"future\",\"date\":\"${datetime}\"}" \
        | jq '{id, title: .title.rendered, status, date, link}'
}

# ─── Pages ───────────────────────────────────────────────────────────────────

cmd_list_pages() {
    local per_page="${1:-20}"
    wp_curl "${WP_SITE_URL}/wp-json/wp/v2/pages?per_page=${per_page}&orderby=date&order=desc" \
        | jq '.[] | {id, title: .title.rendered, status, date, link}'
}

cmd_create_page() {
    local json_file="${1:?JSON file path required}"
    require_file "$json_file"
    wp_curl -X POST "${WP_SITE_URL}/wp-json/wp/v2/pages" \
        -H "Content-Type: application/json" \
        -d @"$json_file" | jq '{id, title: .title.rendered, status, link}'
}

# ─── Media ───────────────────────────────────────────────────────────────────

cmd_list_media() {
    local per_page="${1:-20}"
    wp_curl "${WP_SITE_URL}/wp-json/wp/v2/media?per_page=${per_page}&orderby=date&order=desc" \
        | jq '.[] | {id, title: .title.rendered, source_url, mime_type, date}'
}

cmd_upload_media() {
    local file_path="${1:?File path required}"
    require_file "$file_path"

    local filename
    filename=$(basename "$file_path")
    local ext="${filename##*.}"
    local mime
    case "$ext" in
        jpg|jpeg) mime="image/jpeg" ;;
        png)      mime="image/png" ;;
        gif)      mime="image/gif" ;;
        webp)     mime="image/webp" ;;
        svg)      mime="image/svg+xml" ;;
        pdf)      mime="application/pdf" ;;
        mp4)      mime="video/mp4" ;;
        mp3)      mime="audio/mpeg" ;;
        wav)      mime="audio/wav" ;;
        *)        mime="application/octet-stream" ;;
    esac

    wp_curl -X POST "${WP_SITE_URL}/wp-json/wp/v2/media" \
        -H "Content-Disposition: attachment; filename=${filename}" \
        -H "Content-Type: ${mime}" \
        --data-binary @"$file_path" | jq '{id, source_url, mime_type}'
}

cmd_update_media() {
    local media_id="${1:?Media ID required}"
    local alt_text="${2:-}"
    local caption="${3:-}"

    local data="{}"
    [ -n "$alt_text" ] && data=$(echo "$data" | jq --arg a "$alt_text" '.alt_text = $a')
    [ -n "$caption" ] && data=$(echo "$data" | jq --arg c "$caption" '.caption = $c')

    wp_curl -X POST "${WP_SITE_URL}/wp-json/wp/v2/media/${media_id}" \
        -H "Content-Type: application/json" \
        -d "$data" | jq '{id, alt_text, caption: .caption.rendered}'
}

cmd_delete_media() {
    local media_id="${1:?Media ID required}"
    wp_curl -X DELETE "${WP_SITE_URL}/wp-json/wp/v2/media/${media_id}?force=true" \
        | jq '{id, deleted: true}'
}

cmd_set_featured_image() {
    local post_id="${1:?Post ID required}"
    local media_id="${2:?Media ID required}"
    wp_curl -X POST "${WP_SITE_URL}/wp-json/wp/v2/posts/${post_id}" \
        -H "Content-Type: application/json" \
        -d "{\"featured_media\":${media_id}}" \
        | jq '{id, featured_media}'
}

# ─── Categories ──────────────────────────────────────────────────────────────

cmd_list_categories() {
    wp_curl "${WP_SITE_URL}/wp-json/wp/v2/categories?per_page=100" \
        | jq '.[] | {id, name, slug, count, parent}'
}

cmd_create_category() {
    local name="${1:?Category name required}"
    local slug="${2:-}"
    local parent="${3:-0}"

    local data
    data=$(jq -n --arg n "$name" --arg s "$slug" --argjson p "$parent" \
        '{name: $n, parent: $p} + (if $s != "" then {slug: $s} else {} end)')

    wp_curl -X POST "${WP_SITE_URL}/wp-json/wp/v2/categories" \
        -H "Content-Type: application/json" \
        -d "$data" | jq '{id, name, slug}'
}

cmd_delete_category() {
    local cat_id="${1:?Category ID required}"
    wp_curl -X DELETE "${WP_SITE_URL}/wp-json/wp/v2/categories/${cat_id}?force=true" \
        | jq '{id, deleted: true}'
}

# ─── Tags ────────────────────────────────────────────────────────────────────

cmd_list_tags() {
    local search="${1:-}"
    local url="${WP_SITE_URL}/wp-json/wp/v2/tags?per_page=100"
    [ -n "$search" ] && url="${url}&search=${search}"
    wp_curl "$url" | jq '.[] | {id, name, slug, count}'
}

cmd_create_tag() {
    local name="${1:?Tag name required}"
    wp_curl -X POST "${WP_SITE_URL}/wp-json/wp/v2/tags" \
        -H "Content-Type: application/json" \
        -d "{\"name\":\"${name}\"}" | jq '{id, name, slug}'
}

cmd_delete_tag() {
    local tag_id="${1:?Tag ID required}"
    wp_curl -X DELETE "${WP_SITE_URL}/wp-json/wp/v2/tags/${tag_id}?force=true" \
        | jq '{id, deleted: true}'
}

# ─── Comments ────────────────────────────────────────────────────────────────

cmd_list_comments() {
    local status="${1:-approve}"
    local per_page="${2:-20}"
    wp_curl "${WP_SITE_URL}/wp-json/wp/v2/comments?status=${status}&per_page=${per_page}&orderby=date&order=desc" \
        | jq '.[] | {id, post, author_name, status, date, content: .content.rendered[0:100]}'
}

cmd_pending_comments() {
    wp_curl "${WP_SITE_URL}/wp-json/wp/v2/comments?status=hold&per_page=100" \
        | jq '.[] | {id, post, author_name, date, content: .content.rendered[0:200]}'
}

cmd_approve_comment() {
    local comment_id="${1:?Comment ID required}"
    wp_curl -X POST "${WP_SITE_URL}/wp-json/wp/v2/comments/${comment_id}" \
        -H "Content-Type: application/json" \
        -d '{"status":"approved"}' | jq '{id, status}'
}

cmd_spam_comment() {
    local comment_id="${1:?Comment ID required}"
    wp_curl -X POST "${WP_SITE_URL}/wp-json/wp/v2/comments/${comment_id}" \
        -H "Content-Type: application/json" \
        -d '{"status":"spam"}' | jq '{id, status}'
}

cmd_delete_comment() {
    local comment_id="${1:?Comment ID required}"
    local force="${2:-false}"
    if [ "$force" = "true" ]; then
        wp_curl -X DELETE "${WP_SITE_URL}/wp-json/wp/v2/comments/${comment_id}?force=true" \
            | jq '{id, deleted: true}'
    else
        wp_curl -X DELETE "${WP_SITE_URL}/wp-json/wp/v2/comments/${comment_id}" \
            | jq '{id, status}'
    fi
}

cmd_reply_comment() {
    local comment_id="${1:?Comment ID required}"
    local reply_text="${2:?Reply text required}"

    # Get original comment to find post ID
    local post_id
    post_id=$(wp_curl "${WP_SITE_URL}/wp-json/wp/v2/comments/${comment_id}" | jq -r '.post')

    local data
    data=$(jq -n --arg content "$reply_text" --argjson post "$post_id" --argjson parent "$comment_id" \
        '{content: $content, post: $post, parent: $parent}')

    wp_curl -X POST "${WP_SITE_URL}/wp-json/wp/v2/comments" \
        -H "Content-Type: application/json" \
        -d "$data" | jq '{id, post, parent, status}'
}

cmd_bulk_approve_comments() {
    local approved=0
    local ids
    ids=$(wp_curl "${WP_SITE_URL}/wp-json/wp/v2/comments?status=hold&per_page=100" | jq -r '.[].id')

    for cid in $ids; do
        wp_curl -X POST "${WP_SITE_URL}/wp-json/wp/v2/comments/${cid}" \
            -H "Content-Type: application/json" \
            -d '{"status":"approved"}' > /dev/null
        approved=$((approved + 1))
    done

    echo "{\"approved\": $approved}"
}

# ─── Content: Calendar ───────────────────────────────────────────────────────

cmd_calendar() {
    local month="${1:-$(date +%Y-%m)}"

    # Parse year and month
    local year="${month%-*}"
    local mon="${month#*-}"

    # Calculate date range
    local after="${year}-${mon}-01T00:00:00"
    local next_mon=$((10#$mon + 1))
    local next_year="$year"
    if [ "$next_mon" -gt 12 ]; then
        next_mon=1
        next_year=$((year + 1))
    fi
    local before
    before=$(printf "%s-%02d-01T00:00:00" "$next_year" "$next_mon")

    echo "=== Content Calendar: ${month} ==="
    echo ""

    # Published posts
    echo "PUBLISHED:"
    wp_curl "${WP_SITE_URL}/wp-json/wp/v2/posts?after=${after}&before=${before}&status=publish&per_page=100&orderby=date&order=asc" \
        | jq -r '.[] | "  \(.date[0:10]) \(.date[11:16])  #\(.id) \(.title.rendered)"'

    echo ""
    echo "SCHEDULED:"
    wp_curl "${WP_SITE_URL}/wp-json/wp/v2/posts?after=${after}&before=${before}&status=future&per_page=100&orderby=date&order=asc" \
        | jq -r '.[] | "  \(.date[0:10]) \(.date[11:16])  #\(.id) \(.title.rendered)"'

    echo ""
    echo "DRAFTS:"
    wp_curl "${WP_SITE_URL}/wp-json/wp/v2/posts?after=${after}&before=${before}&status=draft&per_page=100&orderby=date&order=asc" \
        | jq -r '.[] | "  \(.date[0:10]) \(.date[11:16])  #\(.id) \(.title.rendered)"'
}

# ─── Content: Stats ──────────────────────────────────────────────────────────

cmd_stats() {
    echo "=== Site Stats: ${CURRENT_SITE} (${WP_SITE_URL}) ==="
    echo ""

    # Posts by status (use X-WP-Total header)
    for status in publish draft pending private future trash; do
        local total
        total=$(wp_curl -I "${WP_SITE_URL}/wp-json/wp/v2/posts?status=${status}&per_page=1" 2>/dev/null \
            | grep -i '^x-wp-total:' | tr -d '\r' | awk '{print $2}')
        [ -z "$total" ] && total="0"
        printf "  Posts (%-8s): %s\n" "$status" "$total"
    done

    echo ""

    # Pages
    local pages_total
    pages_total=$(wp_curl -I "${WP_SITE_URL}/wp-json/wp/v2/pages?per_page=1" 2>/dev/null \
        | grep -i '^x-wp-total:' | tr -d '\r' | awk '{print $2}')
    echo "  Pages:            ${pages_total:-0}"

    # Media
    local media_total
    media_total=$(wp_curl -I "${WP_SITE_URL}/wp-json/wp/v2/media?per_page=1" 2>/dev/null \
        | grep -i '^x-wp-total:' | tr -d '\r' | awk '{print $2}')
    echo "  Media:            ${media_total:-0}"

    # Categories
    local cats_total
    cats_total=$(wp_curl -I "${WP_SITE_URL}/wp-json/wp/v2/categories?per_page=1" 2>/dev/null \
        | grep -i '^x-wp-total:' | tr -d '\r' | awk '{print $2}')
    echo "  Categories:       ${cats_total:-0}"

    # Tags
    local tags_total
    tags_total=$(wp_curl -I "${WP_SITE_URL}/wp-json/wp/v2/tags?per_page=1" 2>/dev/null \
        | grep -i '^x-wp-total:' | tr -d '\r' | awk '{print $2}')
    echo "  Tags:             ${tags_total:-0}"

    # Comments
    echo ""
    for cstatus in approved hold spam trash; do
        local ctotal
        ctotal=$(wp_curl -I "${WP_SITE_URL}/wp-json/wp/v2/comments?status=${cstatus}&per_page=1" 2>/dev/null \
            | grep -i '^x-wp-total:' | tr -d '\r' | awk '{print $2}')
        [ -z "$ctotal" ] && ctotal="0"
        printf "  Comments (%-8s): %s\n" "$cstatus" "$ctotal"
    done
}

# ─── Bulk Operations ─────────────────────────────────────────────────────────

cmd_bulk_publish() {
    local count=0
    local ids
    ids=$(wp_curl "${WP_SITE_URL}/wp-json/wp/v2/posts?status=draft&per_page=100" | jq -r '.[].id')

    if [ -z "$ids" ]; then
        echo '{"published": 0, "message": "No drafts found"}'
        return
    fi

    echo "Publishing drafts..."
    for pid in $ids; do
        local title
        title=$(wp_curl -X POST "${WP_SITE_URL}/wp-json/wp/v2/posts/${pid}" \
            -H "Content-Type: application/json" \
            -d '{"status":"publish"}' | jq -r '.title.rendered')
        echo "  Published #${pid}: ${title}"
        count=$((count + 1))
    done

    echo ""
    echo "{\"published\": $count}"
}

cmd_bulk_delete_old() {
    local days="${1:-365}"
    local cutoff_date
    cutoff_date=$(date -v-${days}d +%Y-%m-%dT00:00:00 2>/dev/null || date -d "-${days} days" +%Y-%m-%dT00:00:00 2>/dev/null)

    if [ -z "$cutoff_date" ]; then
        echo "Error: could not compute cutoff date" >&2
        return 1
    fi

    local count=0
    local ids
    ids=$(wp_curl "${WP_SITE_URL}/wp-json/wp/v2/posts?before=${cutoff_date}&status=trash&per_page=100" \
        | jq -r '.[].id')

    if [ -z "$ids" ]; then
        echo "{\"deleted\": 0, \"message\": \"No trashed posts older than ${days} days\"}"
        return
    fi

    echo "Permanently deleting trashed posts older than ${days} days..."
    for pid in $ids; do
        wp_curl -X DELETE "${WP_SITE_URL}/wp-json/wp/v2/posts/${pid}?force=true" > /dev/null
        echo "  Deleted #${pid}"
        count=$((count + 1))
    done

    echo ""
    echo "{\"deleted\": $count}"
}

# ─── Export / Backup ─────────────────────────────────────────────────────────

cmd_backup() {
    local output_dir="${1:-${HOME}/clawd/backups}"
    local timestamp
    timestamp=$(date +%Y%m%d-%H%M%S)
    local backup_dir="${output_dir}/wp-backup-${CURRENT_SITE}-${timestamp}"

    mkdir -p "$backup_dir"

    echo "=== Backing up site: ${CURRENT_SITE} ==="
    echo "Output: ${backup_dir}"
    echo ""

    # Posts (all statuses)
    echo "Exporting posts..."
    local page=1
    local all_posts="[]"
    while true; do
        local batch
        batch=$(wp_curl "${WP_SITE_URL}/wp-json/wp/v2/posts?per_page=100&page=${page}&status=any&context=edit" 2>/dev/null)
        local batch_len
        batch_len=$(echo "$batch" | jq 'length' 2>/dev/null || echo 0)
        [ "$batch_len" -eq 0 ] && break
        all_posts=$(echo "$all_posts $batch" | jq -s '.[0] + .[1]')
        page=$((page + 1))
    done
    echo "$all_posts" | jq '.' > "${backup_dir}/posts.json"
    local post_count
    post_count=$(echo "$all_posts" | jq 'length')
    echo "  Posts: $post_count"

    # Pages
    echo "Exporting pages..."
    wp_curl "${WP_SITE_URL}/wp-json/wp/v2/pages?per_page=100&status=any&context=edit" \
        | jq '.' > "${backup_dir}/pages.json"
    local page_count
    page_count=$(jq 'length' "${backup_dir}/pages.json")
    echo "  Pages: $page_count"

    # Categories
    echo "Exporting categories..."
    wp_curl "${WP_SITE_URL}/wp-json/wp/v2/categories?per_page=100" \
        | jq '.' > "${backup_dir}/categories.json"
    local cat_count
    cat_count=$(jq 'length' "${backup_dir}/categories.json")
    echo "  Categories: $cat_count"

    # Tags
    echo "Exporting tags..."
    wp_curl "${WP_SITE_URL}/wp-json/wp/v2/tags?per_page=100" \
        | jq '.' > "${backup_dir}/tags.json"
    local tag_count
    tag_count=$(jq 'length' "${backup_dir}/tags.json")
    echo "  Tags: $tag_count"

    echo ""
    echo "Backup complete: ${backup_dir}"
    echo "  Posts: $post_count, Pages: $page_count, Categories: $cat_count, Tags: $tag_count"
}

cmd_export_markdown() {
    local output_dir="${1:-${HOME}/clawd/exports}"
    local timestamp
    timestamp=$(date +%Y%m%d-%H%M%S)
    local export_dir="${output_dir}/wp-markdown-${CURRENT_SITE}-${timestamp}"

    mkdir -p "$export_dir"

    echo "=== Exporting posts as Markdown: ${CURRENT_SITE} ==="
    echo "Output: ${export_dir}"
    echo ""

    local page=1
    local count=0
    while true; do
        local batch
        batch=$(wp_curl "${WP_SITE_URL}/wp-json/wp/v2/posts?per_page=100&page=${page}&status=any&context=edit" 2>/dev/null)
        local batch_len
        batch_len=$(echo "$batch" | jq 'length' 2>/dev/null || echo 0)
        [ "$batch_len" -eq 0 ] && break

        echo "$batch" | jq -c '.[]' | while read -r post; do
            local pid slug title date status content
            pid=$(echo "$post" | jq -r '.id')
            slug=$(echo "$post" | jq -r '.slug')
            title=$(echo "$post" | jq -r '.title.raw // .title.rendered')
            date=$(echo "$post" | jq -r '.date')
            status=$(echo "$post" | jq -r '.status')
            content=$(echo "$post" | jq -r '.content.raw // .content.rendered')

            local filename="${slug}.md"
            {
                echo "---"
                echo "id: ${pid}"
                echo "title: \"${title}\""
                echo "date: ${date}"
                echo "status: ${status}"
                echo "slug: ${slug}"
                echo "---"
                echo ""
                # Strip HTML tags for a basic markdown conversion
                echo "$content" | sed 's/<br[^>]*>/\n/g; s/<\/p>/\n\n/g; s/<[^>]*>//g'
            } > "${export_dir}/${filename}"
            count=$((count + 1))
        done

        page=$((page + 1))
    done

    echo "Exported $count posts to ${export_dir}"
}

# ─── Site ────────────────────────────────────────────────────────────────────

cmd_site_info() {
    echo "=== Site Info: ${CURRENT_SITE} ==="
    wp_curl "${WP_SITE_URL}/wp-json/" | jq '{name, description, url, home, gmt_offset, timezone_string}'
}

cmd_site_health() {
    echo "=== Site Health: ${CURRENT_SITE} (${WP_SITE_URL}) ==="
    echo ""

    # REST API reachable?
    echo -n "REST API:       "
    local start_time end_time http_code elapsed
    start_time=$(python3 -c "import time; print(int(time.time()*1000))")
    http_code=$(wp_curl -o /dev/null -w "%{http_code}" "${WP_SITE_URL}/wp-json/wp/v2/posts?per_page=1")
    end_time=$(python3 -c "import time; print(int(time.time()*1000))")

    if [ "$http_code" = "200" ]; then
        elapsed=$(( end_time - start_time ))
        echo "OK (${http_code}, ${elapsed}ms)"
    else
        echo "ERROR (HTTP ${http_code})"
    fi

    # Auth check
    echo -n "Authentication: "
    local auth_code
    auth_code=$(wp_curl -o /dev/null -w "%{http_code}" "${WP_SITE_URL}/wp-json/wp/v2/users/me")
    if [ "$auth_code" = "200" ]; then
        local user_name user_roles
        user_name=$(wp_curl "${WP_SITE_URL}/wp-json/wp/v2/users/me" | jq -r '.name')
        user_roles=$(wp_curl "${WP_SITE_URL}/wp-json/wp/v2/users/me?context=edit" | jq -r '.roles | join(", ")' 2>/dev/null || echo "unknown")
        echo "OK (${user_name}, roles: ${user_roles})"
    else
        echo "FAILED (HTTP ${auth_code})"
    fi

    # Permalink structure
    echo -n "Permalinks:     "
    local sample_link
    sample_link=$(wp_curl "${WP_SITE_URL}/wp-json/wp/v2/posts?per_page=1" | jq -r '.[0].link // "none"')
    echo "$sample_link"

    # Yoast check
    echo -n "Yoast SEO:      "
    local yoast_code
    yoast_code=$(wp_curl -o /dev/null -w "%{http_code}" "${WP_SITE_URL}/wp-json/yoast/v1/get_head?url=${WP_SITE_URL}")
    [ "$yoast_code" = "200" ] && echo "Detected" || echo "Not found"

    # RankMath check
    echo -n "RankMath:       "
    local rm_code
    rm_code=$(wp_curl -o /dev/null -w "%{http_code}" "${WP_SITE_URL}/wp-json/rankmath/v1/getHead?url=${WP_SITE_URL}")
    [ "$rm_code" = "200" ] && echo "Detected" || echo "Not found"
}

cmd_me() {
    wp_curl "${WP_SITE_URL}/wp-json/wp/v2/users/me?context=edit" \
        | jq '{id, name, slug, email, roles, capabilities: (.capabilities | keys)}'
}

cmd_list_users() {
    wp_curl "${WP_SITE_URL}/wp-json/wp/v2/users?per_page=50" \
        | jq '.[] | {id, name, slug}'
}

# ─── Parse CLI args ─────────────────────────────────────────────────────────

SITE_FLAG=""
COMMAND=""
ARGS=()

for arg in "$@"; do
    case "$arg" in
        --site=*) SITE_FLAG="${arg#--site=}" ;;
        *)
            if [ -z "$COMMAND" ]; then
                COMMAND="$arg"
            else
                ARGS+=("$arg")
            fi
            ;;
    esac
done

if [ -z "$COMMAND" ]; then
    echo "Usage: wp-rest.sh <command> [args...] [--site=NAME]"
    echo ""
    echo "Commands:"
    echo "  POSTS:      list-posts, get-post, search-posts, create-post,"
    echo "              create-post-markdown, update-post, delete-post,"
    echo "              publish-post, schedule-post"
    echo "  PAGES:      list-pages, create-page"
    echo "  MEDIA:      list-media, upload-media, update-media, delete-media,"
    echo "              set-featured-image"
    echo "  CATEGORIES: list-categories, create-category, delete-category"
    echo "  TAGS:       list-tags, create-tag, delete-tag"
    echo "  COMMENTS:   list-comments, pending-comments, approve-comment,"
    echo "              spam-comment, delete-comment, reply-comment,"
    echo "              bulk-approve-comments"
    echo "  CONTENT:    health-check, calendar, stats"
    echo "  BULK:       bulk-publish, bulk-delete-old"
    echo "  EXPORT:     backup, export-markdown"
    echo "  SITE:       site-info, site-health, me, list-users"
    echo ""
    echo "Options:"
    echo "  --site=NAME   Select which site to use (default: from config)"
    exit 0
fi

# Initialize auth
setup_auth "$SITE_FLAG"

# Dispatch
case "$COMMAND" in
    # Posts
    list-posts)              cmd_list_posts "${ARGS[@]:-}" ;;
    get-post)                cmd_get_post "${ARGS[0]:-}" ;;
    search-posts)            cmd_search_posts "${ARGS[0]:-}" ;;
    create-post)             cmd_create_post "${ARGS[0]:-}" ;;
    create-post-markdown)    cmd_create_post_markdown "${ARGS[@]:-}" ;;
    update-post)             cmd_update_post "${ARGS[0]:-}" "${ARGS[1]:-}" ;;
    delete-post)             cmd_delete_post "${ARGS[0]:-}" "${ARGS[1]:-}" ;;
    publish-post)            cmd_publish_post "${ARGS[0]:-}" ;;
    schedule-post)           cmd_schedule_post "${ARGS[0]:-}" "${ARGS[1]:-}" ;;

    # Pages
    list-pages)              cmd_list_pages "${ARGS[@]:-}" ;;
    create-page)             cmd_create_page "${ARGS[0]:-}" ;;

    # Media
    list-media)              cmd_list_media "${ARGS[@]:-}" ;;
    upload-media)            cmd_upload_media "${ARGS[0]:-}" ;;
    update-media)            cmd_update_media "${ARGS[0]:-}" "${ARGS[1]:-}" "${ARGS[2]:-}" ;;
    delete-media)            cmd_delete_media "${ARGS[0]:-}" ;;
    set-featured-image)      cmd_set_featured_image "${ARGS[0]:-}" "${ARGS[1]:-}" ;;

    # Categories
    list-categories)         cmd_list_categories ;;
    create-category)         cmd_create_category "${ARGS[0]:-}" "${ARGS[1]:-}" "${ARGS[2]:-0}" ;;
    delete-category)         cmd_delete_category "${ARGS[0]:-}" ;;

    # Tags
    list-tags)               cmd_list_tags "${ARGS[0]:-}" ;;
    create-tag)              cmd_create_tag "${ARGS[0]:-}" ;;
    delete-tag)              cmd_delete_tag "${ARGS[0]:-}" ;;

    # Comments
    list-comments)           cmd_list_comments "${ARGS[0]:-approve}" "${ARGS[1]:-20}" ;;
    pending-comments)        cmd_pending_comments ;;
    approve-comment)         cmd_approve_comment "${ARGS[0]:-}" ;;
    spam-comment)            cmd_spam_comment "${ARGS[0]:-}" ;;
    delete-comment)          cmd_delete_comment "${ARGS[0]:-}" "${ARGS[1]:-}" ;;
    reply-comment)           cmd_reply_comment "${ARGS[0]:-}" "${ARGS[1]:-}" ;;
    bulk-approve-comments)   cmd_bulk_approve_comments ;;

    # Content
    health-check)            content_health_check "${ARGS[0]:-}" ;;
    calendar)                cmd_calendar "${ARGS[0]:-}" ;;
    stats)                   cmd_stats ;;

    # Bulk
    bulk-publish)            cmd_bulk_publish ;;
    bulk-delete-old)         cmd_bulk_delete_old "${ARGS[0]:-365}" ;;

    # Export
    backup)                  cmd_backup "${ARGS[0]:-}" ;;
    export-markdown)         cmd_export_markdown "${ARGS[0]:-}" ;;

    # Site
    site-info)               cmd_site_info ;;
    site-health)             cmd_site_health ;;
    me)                      cmd_me ;;
    list-users)              cmd_list_users ;;

    *)
        echo "Unknown command: $COMMAND" >&2
        echo "Run 'wp-rest.sh' without arguments for usage." >&2
        exit 1
        ;;
esac
