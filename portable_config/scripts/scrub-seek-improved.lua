-- scrub-seek-improved.lua
-- mpv.net専用 - ウィンドウドラッグエリアを避けたスクラブシーク
-- KeyframeMPX風の操作感を実現

local mp = require 'mp'
local msg = require 'mp.msg'

-- 状態管理
local state = {
    mouse_down = false,
    dragging = false,
    start_x = 0,
    start_y = 0,
    last_x = 0,
    start_time_pos = 0,
    click_start_time = 0,
    safe_area = false,
}

-- 設定値
local opts = {
    sensitivity = 0.15,
    drag_threshold = 5,
    click_threshold = 0.2,
    osc_height = 80,
    
    -- デッドゾーン設定
    top_deadzone = 0.10,
    left_deadzone = 0.10,
    right_deadzone = 0.10,
    bottom_deadzone = 0.22,
    
    debug = true,
}

-- エリア判定
local function get_safe_area_type(x, y)
    local screen_w, screen_h = mp.get_osd_size()
    
    if not screen_w or not screen_h then
        return "unknown"
    end
    
    -- OSCエリア（最優先で除外）
    if y > (screen_h - opts.osc_height) then
        return "osc"
    end
    
    -- 各デッドゾーンの判定（安全エリア）
    local in_top = y < (screen_h * opts.top_deadzone)
    local in_bottom = y > (screen_h * (1 - opts.bottom_deadzone)) and y <= (screen_h - opts.osc_height)
    local in_left = x < (screen_w * opts.left_deadzone)
    local in_right = x > (screen_w * (1 - opts.right_deadzone))
    
    if in_top or in_bottom or in_left or in_right then
        return "safe"
    end
    
    return "center"
end

-- シーク実行
local function perform_seek(time_offset)
    if math.abs(time_offset) < 0.01 then return end
    
    local current_pos = mp.get_property_number("time-pos")
    local duration = mp.get_property_number("duration")
    
    if not current_pos or not duration then return end
    
    local new_pos = current_pos + time_offset
    new_pos = math.max(0, math.min(new_pos, duration))
    
    mp.commandv("seek", new_pos, "absolute+exact")
    
    if opts.debug then
        msg.info(string.format("✓ Seek: %.2fs + %.2fs = %.2fs", 
            current_pos, time_offset, new_pos))
    end
end

-- マウス位置監視
local mouse_pos_observer = function(name, pos)
    if not pos then return end
    
    local mx, my = pos.x, pos.y
    if not mx or not my then return end

    -- マウスダウン中のみ処理
    if not state.mouse_down then return end
    
    -- ドラッグ開始判定
    if not state.dragging then
        local dx = mx - state.start_x
        local dy = my - state.start_y
        local distance = math.sqrt(dx*dx + dy*dy)
        
        if distance > opts.drag_threshold then
            state.dragging = true
            if opts.debug then
                msg.info(string.format("✓ Drag started (dist: %.1fpx)", distance))
            end
        end
    end
    
    -- ドラッグ中のシーク
    if state.dragging and state.safe_area then
        local delta_x = mx - state.last_x
        local time_offset = delta_x * opts.sensitivity
        
        if math.abs(time_offset) > 0.01 then
            perform_seek(time_offset)
            state.last_x = mx
        end
    end
end

-- マウスダウン処理
local function on_mouse_down()
    local mx, my = mp.get_mouse_pos()
    if not mx or not my then return end
    
    local area_type = get_safe_area_type(mx, my)
    
    if opts.debug then
        msg.info(string.format("Mouse DOWN at (%d,%d) - area: %s", mx, my, area_type))
    end
    
    -- OSCエリアは完全無視
    if area_type == "osc" then
        return
    end
    
    -- 中央エリアは警告を出して処理しない
    if area_type == "center" then
        if opts.debug then
            msg.warn("⚠ Center area - skipping (window drag zone)")
        end
        return
    end
    
    -- 安全エリアのみ処理を開始
    state.mouse_down = true
    state.safe_area = (area_type == "safe")
    state.start_x = mx
    state.start_y = my
        state.last_x = mx
    state.click_start_time = mp.get_time()
    state.dragging = false
    
    -- 現在位置を記録
    state.start_time_pos = mp.get_property_number("time-pos") or 0
    
    if opts.debug then
        msg.info("✓ Ready to scrub - drag left/right to seek")
    end
end

-- マウスアップ処理
local function on_mouse_up()
    if not state.mouse_down then return end
    
    local mx, my = mp.get_mouse_pos()
    if not mx or not my then
        state.mouse_down = false
        return
    end
    
    local elapsed = mp.get_time() - state.click_start_time
    
    if opts.debug then
        msg.info(string.format("Mouse UP at (%d,%d) - dragging: %s", 
            mx, my, tostring(state.dragging)))
    end
    
    -- クリック判定（短時間 + 移動距離が小さい）
    if not state.dragging and elapsed < opts.click_threshold then
        local dx = mx - state.start_x
        local dy = my - state.start_y
        local distance = math.sqrt(dx*dx + dy*dy)
        
        if distance < opts.drag_threshold then
            mp.commandv("cycle", "pause")
            if opts.debug then
                msg.info("✓ Click detected - toggled pause")
            end
        end
    end
    
    -- 状態リセット
    state.mouse_down = false
    state.dragging = false
    state.safe_area = false
    
    if opts.debug then
        msg.info("✓ Mouse released")
    end
end

-- ダブルクリック処理
local function on_double_click()
    local mx, my = mp.get_mouse_pos()
    if not mx or not my then return end
    
    local area_type = get_safe_area_type(mx, my)
    
    if area_type == "safe" then
        mp.commandv("cycle", "fullscreen")
        if opts.debug then
            msg.info("✓ Double-click - toggled fullscreen")
        end
    end
end

-- マウス位置プロパティの監視
mp.observe_property("mouse-pos", "native", mouse_pos_observer)

-- キーバインディング
mp.add_forced_key_binding("MBTN_LEFT", "scrub_mouse_down", on_mouse_down)
mp.add_forced_key_binding("MBTN_LEFT_UP", "scrub_mouse_up", on_mouse_up)
mp.add_forced_key_binding("MBTN_LEFT_DBL", "scrub_double_click", on_double_click)

-- 起動メッセージ
msg.info("===========================================")
msg.info("Scrub Seek v2 (Mouse Property Observer)")
msg.info("===========================================")
msg.info("✓ Safe zones: Edges (Top/Left/Right/Bottom)")
msg.info("⚠ Avoid: Center area (window drag zone)")
msg.info("✓ OSC area excluded: bottom " .. opts.osc_height .. "px")
msg.info("-------------------------------------------")
msg.info("Usage:")
msg.info("  • Drag in safe zones = Seek")
msg.info("  • Click = Pause/Play")
msg.info("  • Double-click = Fullscreen")
msg.info("===========================================")