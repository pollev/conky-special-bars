--[[
Clock Rings by Linux Mint (2011) reEdited by despot77
Original script extended for vertical bar support by pollev (2018)

This script draws percentage meters as rings, clock hands and vertical bars! It is fully customisable; all options are described in the script.

IMPORTANT: if you are using the 'cpu' function, it will cause a segmentation fault if it tries to draw a ring straight away. The if statement on line 145 uses a delay to make sure that this doesn't happen. It calculates the length of the delay by the number of updates since Conky started. Generally, a value of 5s is long enough, so if you update Conky every 1s, use update_num>5 in that if statement (the default). If you only update Conky every 2s, you should change it to update_num>3; conversely if you update Conky every 0.5s, you should use update_num>10. ALSO, if you change your Conky, is it best to use "killall conky; conky" to update it, otherwise the update_num will not be reset and you will get an error.

To call this script in Conky, use the following (assuming that you save this script to ~/scripts/rings.lua):
    lua_load = '~/scripts/special_bars.lua'
    lua_draw_hook_pre = 'special_bars'

]]

-- Edit this table to customise your bars.
-- You can create more rings simply by adding more elements to settings_table.
-- "name" is the type of stat to display; you can choose from 'cpu', 'memperc', 'fs_used_perc', 'battery_used_perc'.
-- "arg" is the argument to the stat type, e.g. if in Conky you would write ${cpu cpu0}, 'cpu0' would be the argument. If you would not use an argument in the Conky variable, use ''.
-- "bar_type" 1=ring 2=vertical
-- "max" is the maximum value of the bar. If the Conky variable outputs a percentage, use 100.
-- "bg_colour" is the background colour of the bar.
-- "bg_alpha" is the alpha value of the background bar.
-- "fg_colour" is the colour of the indicator part of the bar.
-- "fg_alpha" is the alpha value of the indicator part of the bar.
-- "x" and "y" are the x and y coordinates. [Ring = Center of the ring] [Bar = Bottom-middle of the bar], relative to the top left corner of the Conky window.
-- "thickness" is the thickness of the bar, or ring centred around the radius.
--
-- The following three options are only relevant for bar_type 1 (ring)
-- "radius" is the radius of the ring.
-- "start_angle" is the starting angle of the ring, in degrees, clockwise from top. Value can be either positive or negative.
-- "end_angle" is the ending angle of the ring, in degrees, clockwise from top. Value can be either positive or negative, but must be larger than start_angle.
--
-- The following options are only relevant for bar_type 2 (vertical)
-- "length" is the length of the bar.
-- "fg_colour2" The bar will be a gradient from fg_colour to fg_colour2. If you do not care about a gradient color, make this the same as fg_colour
--
settings_table = {
    {
        name='fs_used_perc',
        arg='/',
        bar_type=1,
        max=100,
        bg_colour=0x0B8904,
        bg_alpha=0.2,
        fg_colour=0x70C66C,
        fg_alpha=0.8,
        x=143, y=770,
        radius=30,
        thickness=5,
        start_angle=-90,
        end_angle=180
    },
    {
        name='fs_used_perc',
        arg='/home/polle/data',
        bar_type=1,
        max=100,
        bg_colour=0x0B8904,
        bg_alpha=0.2,
        fg_colour=0x70C66C,
        fg_alpha=0.8,
        x=268, y=770,
        radius=30,
        thickness=5,
        start_angle=-90,
        end_angle=180
    },
    {
        name='cpu',
        arg='cpu0',
        bar_type=2,
        max=100,
        bg_colour=0x0B8904,
        bg_alpha=0.2,
        fg_colour=0x70C66C,
        fg_colour2=0xf45042,
        fg_alpha=0.8,
        x=90, y=355,
        thickness=8,
        length=75
    },
    {
        name='memperc',
        arg='',
        bar_type=2,
        max=100,
        bg_colour=0x0B8904,
        bg_alpha=0.2,
        fg_colour=0x70C66C,
        fg_colour2=0xf45042,
        fg_alpha=0.8,
        x=90, y=575,
        thickness=8,
        length=75
    },
}

require 'cairo'

function rgb_to_r_g_b(colour,alpha)
    return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
end

function draw_bar(cr,pct,pt)
    local xc,yc,line_width,length = pt['x'], pt['y'], pt['thickness'], pt['length']
    local bgc, bga, fgc, fgc2, fga=pt['bg_colour'], pt['bg_alpha'], pt['fg_colour'], pt['fg_colour2'], pt['fg_alpha']

    if pct<0.01 then
        pct = 0.01
    end

    -- Draw background bar
    cairo_set_source_rgba(cr, rgb_to_r_g_b(bgc,bga))
    cairo_set_line_width(cr, line_width)
    cairo_move_to(cr, (line_width / 2) + xc, yc)
    cairo_line_to(cr, (line_width / 2) + xc, yc - length)
    cairo_stroke (cr)

    -- Draw foreground bar
    pat = cairo_pattern_create_linear(0.0, yc - length,  0.0, yc);
    cairo_pattern_add_color_stop_rgba(pat, 1, rgb_to_r_g_b(fgc,fga));
    cairo_pattern_add_color_stop_rgba(pat, 0, rgb_to_r_g_b(fgc2,fga));
    cairo_set_source(cr, pat);
    cairo_set_line_width(cr, line_width)
    cairo_move_to(cr, (line_width / 2) + xc, yc)
    cairo_line_to(cr, (line_width / 2) + xc, yc - (length * pct))
    cairo_stroke(cr)

end

function draw_ring(cr,pct,pt)
    local w=conky_window.width
    local h=conky_window.height

    local xc, yc, ring_r, ring_w, sa, ea=pt['x'], pt['y'], pt['radius'], pt['thickness'], pt['start_angle'], pt['end_angle']
    local bgc, bga, fgc, fga=pt['bg_colour'], pt['bg_alpha'], pt['fg_colour'], pt['fg_alpha']

    local angle_0=sa*(2*math.pi/360)-math.pi/2
    local angle_f=ea*(2*math.pi/360)-math.pi/2
    local t_arc=pct*(angle_f-angle_0)

    -- Draw background ring
    cairo_arc(cr,xc,yc,ring_r,angle_0,angle_f)
    cairo_set_source_rgba(cr,rgb_to_r_g_b(bgc,bga))
    cairo_set_line_width(cr,ring_w)
    cairo_stroke(cr)

    -- Draw indicator ring
    cairo_arc(cr,xc,yc,ring_r,angle_0,angle_0+t_arc)
    cairo_set_source_rgba(cr,rgb_to_r_g_b(fgc,fga))
    cairo_stroke(cr)
end

function conky_special_bars()
    local function setup_value(cr,pt)
        local str=''
        local value=0

        str=string.format('${%s %s}',pt['name'],pt['arg'])
        str=conky_parse(str)

        value=tonumber(str)
        pct=value/pt['max']

        if pt['bar_type']==1 then
            draw_ring(cr,pct,pt)
        elseif pt['bar_type']==2 then
            draw_bar(cr,pct,pt)
        else
            print(string.format("Bar type %d not supported\n",pt['bar_type']))
        end
    end

    -- Check that Conky has been running for at least 5s

    if conky_window==nil then return end
    local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual, conky_window.width,conky_window.height)
    local cr=cairo_create(cs)

    local updates=conky_parse('${updates}')
    update_num=tonumber(updates)

    if update_num>5 then
        for i in pairs(settings_table) do
            setup_value(cr,settings_table[i])
        end
    end
end

