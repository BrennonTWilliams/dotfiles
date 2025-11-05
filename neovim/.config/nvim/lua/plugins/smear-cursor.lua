return {
  "sphamba/smear-cursor.nvim",
  opts = {
    -- Smear cursor when switching buffers or windows
    smear_between_buffers = true,
    smear_between_neighbor_lines = true,

    -- Draw smear in buffer space instead of screen space when scrolling
    scroll_buffer_space = true,

    -- Smear cursor in insert mode
    smear_insert_mode = true,

    -- Set to true if font supports legacy computing symbols
    legacy_computing_symbols_support = false,

    -- Optimized animation settings for smoother experience
    stiffness = 0.8,              -- Increased for faster smear (default: 0.6)
    trailing_stiffness = 0.6,     -- Increased for less trail (default: 0.45)
    stiffness_insert_mode = 0.7,  -- Insert mode specific stiffness
    trailing_stiffness_insert_mode = 0.7, -- Insert mode trailing stiffness
    damping = 0.95,               -- Increased for smoother animations (default: 0.85)
    damping_insert_mode = 0.95,   -- Insert mode damping
    distance_stop_animating = 0.5, -- Distance to stop animating (default: 0.1)

    -- Animation timing for better performance
    time_interval = 17,           -- milliseconds between frames (default: 17ms)

    -- Cursor color (will inherit from colorscheme if not set)
    -- Uncomment to match your terminal cursor color
    -- cursor_color = "#d3869b",

    -- Matrix pixel threshold for smoother cursor
    matrix_pixel_threshold = 0.4,
  },
}
