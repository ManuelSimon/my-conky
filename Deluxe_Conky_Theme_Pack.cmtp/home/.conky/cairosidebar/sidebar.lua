--[[ CairoSideBar by jpope
    Most work here done by other conky masters with some slight modifications. ;)
    v1.0.2011.09.30
 ]]
 
--[[
Conky Widgets by londonali1010 (2009)

This script is meant to be a "shell" to hold a suite of widgets for use in Conky.

To configure:
+ Copy the widget's code block (will be framed by --(( WIDGET NAME )) and --(( END WIDGET NAME )), with "[" instead of "(") somewhere between "require 'cairo'" and "function conky_widgets()", ensuring not to paste into another widget's code block
+ To call the widget, add the following between "cr = cairo_create(cs)" and "cairo_destroy(cr)" at the end of the script:
	NAME_OF_FUNCTION(cr, OPTIONS)
+ Replace OPTIONS with the options for your widget (should be specified in the widget's code block) 

Call this script in Conky using the following before TEXT (assuming you save this script to ~/scripts/conky_widgets.lua):
	lua_load ~/scripts/conky_widgets.lua
	lua_draw_hook_pre widgets
	
Changelog:
+ v1.1 -- Simplified calls to widgets by implementing a global drawing surface, and included imlib2 by default (03.11.2009)
+ v1.0 -- Original release (17.10.2009)
]]

require 'cairo'
require 'imlib2'

usrhome = os.getenv("HOME")

--[[ USER OPTIONS ]]

clockface=3

color01=0x000000        --original 0x909090
color02=0xFFFFFF        --original 0xFFFFFF
color03=0xFF0000        --original 0xFF0000
color04=0x606060        --original 0x707070

--[[ END USER OPTIONS ]]
    
--[[ ROUNDED RECTANGLE WIDGET ]]
--[[ v1.0 by londonali1010 (2009) ]]
--[[ Options (x0, y0, width, height, radius, colour, alpha):
	"x0" and "y0" are the coordinates (in pixels) of the top left of the rectangle, relative to the top left of the Conky window.
	"width" and "height" are the width and height of the rectangle, respectively.
	"radius" is the rounding radius of the corners, in pixels.
	"colour" is the colour of the rectangle, in format 0xRRGGBB.
	"alpha" is the transparency of the rectangle, from 0.0 (transparent) -> 1.0 (opaque) ]]

function round_rect(x0, y0, w, h, r, colour, alpha)
	local function rgb_to_r_g_b(colour, alpha)
		return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
	end

    local updates=conky_parse('${updates}')
    update_num=tonumber(updates)
    if update_num>5 then
	
	cairo_move_to(cr, x0, y0)
	cairo_rel_move_to(cr, r, 0)
	cairo_rel_line_to(cr, w-2*r, 0)
	cairo_rel_curve_to(cr, r, 0, r, 0, r, r)
	cairo_rel_line_to(cr, 0, h-2*r)
	cairo_rel_curve_to(cr, 0, r, 0, r, -r, r)
	cairo_rel_line_to(cr, -(w-2*r), 0)
	cairo_rel_curve_to(cr, -r, 0, -r, 0, -r, -r)
	cairo_rel_line_to(cr, 0, -(h-2*r))
	cairo_rel_curve_to(cr, 0, -r, 0, -r, r, -r)
	cairo_close_path(cr)

	cairo_set_source_rgba(cr, rgb_to_r_g_b(colour, alpha))
	cairo_fill(cr)
    end
end
	
--[[ END ROUNDED RECTANGLE WIDGET ]]

--[[ PRINT TEXT ]]
--[[ jpope 2011.09.30 ]]
--[[ based on SHINY CALENDAR PAGE WIDGET v1.0 by londonali1010 (2009) ]]
--[[ Options (xcc, ycc, size, bg_colour, fg_colour, alpha)
--	"xcc" and "ycc" are the x and y coordinates of the centre of the widget, in pixels, relative to the top left of the Conky window.
--	"size" is the width of the widget (which is square).
--	"bg_colour" is the colour, in format 0xRRGGBB, of the widget's background.
--	"fg_colour" is the colour of the widget's text.
--	"alpha" is the opacity (0.0 -> 1.0) of the widget. ]]

function printtext(xcc, ycc, size, bgc, fgc, alpha)
	local function rgb_to_r_g_b(colour, alpha)
		return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
	end
	
    local updates=conky_parse('${updates}')
    update_num=tonumber(updates)
    if update_num>5 then

	local function set_font_sizes()
		day_size = 1.0
		date_size = 1.0
		month_size = 1.0
		var_size = 1.0
		data_size = 1.0
		
		local extents = cairo_text_extents_t:create()
		cairo_select_font_face(cr, "Droid Sans", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
		cairo_set_font_size(cr, day_size)
		cairo_text_extents(cr, day, extents)
		local w = math.abs(extents.width)
		local h = math.abs(extents.y_bearing)
		local scale_w = 0.8*size / w
		local scale_h = 0.1*size / h
		local scale
		if scale_w < scale_h then scale = scale_w else scale = scale_h end
		day_size = scale * day_size

		cairo_set_font_size(cr, date_size)
		cairo_text_extents(cr, date, extents)
		w = math.abs(extents.width)
		h = math.abs(extents.y_bearing)
		scale_w = 0.6*size / w
		scale_h = 0.6*size / h
		if scale_w < scale_h then scale = scale_w else scale = scale_h end
		date_size = scale * date_size

		cairo_set_font_size(cr, month_size)
		cairo_text_extents(cr, month, extents)
		w = math.abs(extents.width)
		h = math.abs(extents.y_bearing)
		scale_w = 0.8*size / w
		scale_h = 0.1*size / h
		if scale_w < scale_h then scale = scale_w else scale = scale_h end
		month_size = scale * month_size

		cairo_set_font_size(cr, var_size)
		cairo_text_extents(cr, var, extents)
		w = math.abs(extents.width)
		h = math.abs(extents.y_bearing)
		scale_w = 0.9*size / w
		scale_h = 0.09*size / h
		if scale_w < scale_h then scale = scale_w else scale = scale_h end
		var_size = scale * var_size

		cairo_set_font_size(cr, data_size)
		cairo_text_extents(cr, data, extents)
		w = math.abs(extents.width)
		h = math.abs(extents.y_bearing)
		scale_w = 0.9*size / w
		scale_h = 0.06*size / h
		if scale_w < scale_h then scale = scale_w else scale = scale_h end
		data_size = scale * data_size
			
		return day_size, date_size, month_size, var_size, data_size
	end

	local function draw_text()
		local extents = cairo_text_extents_t:create()
		cairo_set_source_rgba(cr, rgb_to_r_g_b(fgc, alpha))

		cairo_set_font_size(cr, day_size)
		cairo_text_extents(cr, day, extents)
		cairo_move_to(cr, x0 + size/2 - extents.x_advance/2, y0 + 0.35*size)
		cairo_show_text(cr, day)

		cairo_set_font_size(cr, date_size)
		cairo_text_extents(cr, date, extents)
		cairo_move_to(cr, x0 + size/2 - extents.x_advance/2, y0 + 0.5*size - extents.y_bearing/2)
		cairo_show_text(cr, date)

		cairo_set_font_size(cr, month_size)
		cairo_text_extents(cr, month, extents)
		cairo_move_to(cr, x0 + size/2 - extents.x_advance/2, y0 + 0.70*size)
		cairo_show_text(cr, month)
		
		var = "CPU"
		cairo_set_font_size(cr, var_size)
		cairo_text_extents(cr, var, extents)
		cairo_move_to(cr, x0 + size/2 - extents.x_advance/2, y0 + 0.95*size)
		cairo_show_text(cr, var)

		data = conky_parse('${cpu cpu0}%')
		cairo_set_font_size(cr, data_size)
		cairo_text_extents(cr, data, extents)
		cairo_move_to(cr, x0 + size/2 - extents.x_advance/2, y0 + 1.02*size)
		cairo_show_text(cr, data)

		data = conky_parse('${hwmon temp 1}C')
		cairo_set_font_size(cr, data_size)
		cairo_text_extents(cr, data, extents)
		cairo_move_to(cr, x0 + size/2 - extents.x_advance/2 - 2, y0 + 1.09*size)
		cairo_show_text(cr, data)

		var = "MEM"
		cairo_set_font_size(cr, var_size)
		cairo_text_extents(cr, var, extents)
		cairo_move_to(cr, x0 + size/2 - extents.x_advance/2, y0 + 1.2*size)
		cairo_show_text(cr, var)

		data = conky_parse('${memperc}%')
		cairo_set_font_size(cr, data_size)
		cairo_text_extents(cr, data, extents)
		cairo_move_to(cr, x0 + size/2 - extents.x_advance/2, y0 + 1.27*size)
		cairo_show_text(cr, data)

		data = conky_parse('${mem}')
		cairo_set_font_size(cr, data_size)
		cairo_text_extents(cr, data, extents)
		cairo_move_to(cr, x0 + size/2 - extents.x_advance/2 - 2, y0 + 1.34*size)
		cairo_show_text(cr, data)

		var = "Battery"
		cairo_set_font_size(cr, var_size)
		cairo_text_extents(cr, var, extents)
		cairo_move_to(cr, x0 + size/2 - extents.x_advance/2, y0 + 1.57*size)
		cairo_show_text(cr, var)

		data = conky_parse('${battery_percent}%')
		cairo_set_font_size(cr, data_size)
		cairo_text_extents(cr, data, extents)
		cairo_move_to(cr, x0 + size/2 - extents.x_advance/2, y0 + 1.64*size)
		cairo_show_text(cr, data)

		data = conky_parse('${battery_time}')
		cairo_set_font_size(cr, data_size)
		cairo_text_extents(cr, data, extents)
		cairo_move_to(cr, x0 + size/2 - extents.x_advance/2, y0 + 1.71*size)
		cairo_show_text(cr, data)

		var = "Wireless"
		cairo_set_font_size(cr, var_size)
		cairo_text_extents(cr, var, extents)
		cairo_move_to(cr, x0 + size/2 - extents.x_advance/2, y0 + 1.82*size)
		cairo_show_text(cr, var)

		data = conky_parse('${wireless_link_qual_perc wlan0}%')
		cairo_set_font_size(cr, data_size)
		cairo_text_extents(cr, data, extents)
		cairo_move_to(cr, x0 + size/2 - extents.x_advance/2 - 2, y0 + 1.89*size)
		cairo_show_text(cr, data)

		data = conky_parse('u:${upspeed wlan0}|d:${downspeed wlan0}')
		cairo_set_font_size(cr, data_size)
		cairo_text_extents(cr, data, extents)
		cairo_move_to(cr, x0 + size/2 - extents.x_advance/2, y0 + 1.96*size)
		cairo_show_text(cr, data)

		var = "Jesse's Conky Pack"
		cairo_set_font_size(cr, var_size)
		cairo_text_extents(cr, var, extents)
		cairo_move_to(cr, x0 + size/2 - extents.x_advance/2, y0 + 2.19*size)
		cairo_show_text(cr, var)

		data = conky_parse("Updates: ${execi 1 cat ~/.config/conky/cairosidebar/upd}")
		cairo_set_font_size(cr, data_size)
		cairo_text_extents(cr, data, extents)
		cairo_move_to(cr, x0 + size/2 - extents.x_advance/2, y0 + 2.26*size)
		cairo_show_text(cr, data)

		cairo_select_font_face(cr, "OpenLogos", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
		var = "J"
		cairo_set_font_size(cr, var_size*2)
		cairo_text_extents(cr, var, extents)
		cairo_move_to(cr, x0 + size/2 - extents.x_advance/2, y0 + 2.44*size)
		cairo_show_text(cr, var)
	end

	x0, y0 = xcc - size/2, ycc - size/2	
	day = os.date("%A")
	date = os.date("%d")
	month = os.date("%B")

	day_size, date_size, month_size = set_font_sizes()
	draw_text(day_size, date_size, month_size)
    end
end

--[[ END PRINT TEXT ]]

--[[ GUAGE CLOCK WIDGET VERSION 2 ]]
--[[ Options (xc, yc, size, rpt, clr, alp, hrt, mst, thck):
    "xc" and "yc" are the x and y coordinates of the centre of the clock, in pixels, relative to the top left of the Conky window
    "size" is the total size of the widget, in pixels 
    "rpt" is the number of times to repeat the clock hands
    "clr" = color
    "alp" = alpha
    "hrt" is the amount of space between the repeating hands for the hours
    "mst" is the number of space between the repeating hands for seconds & minutes
    "thck" is the starting thickness ]]

function guage_clockv2(cr, xc, yc, size, rpt, clr, clr2, alp, hrt, mst, thck)
    local function rgb_to_r_g_b(colour,alpha)
        return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
    end
    local updates=conky_parse('${updates}')
    update_num=tonumber(updates)
    if update_num>5 then
        local offset = 0
        local clock_r = (size - 2 * offset) / (2 * 1.25)
        show_seconds=true
        -- Grab time
        local hours=os.date("%I")
        local mins=os.date("%M")
        local secs=os.date("%S")
        secs_arc=(2*math.pi/60)*secs
        mins_arc=(2*math.pi/60)*mins--+secs_arc/60
        hours_arc=(2*math.pi/12)*hours+mins_arc/12
        -- Background
            lp=0
            mark=(2*math.pi)/12
            repeat 
                xss=xc+0.80*clock_r*math.sin(mark+mark*lp)
                yss=yc-0.80*clock_r*math.cos(mark+mark*lp)
                xs=xc+1.04*clock_r*math.sin(mark+mark*lp)
                ys=yc-1.04*clock_r*math.cos(mark+mark*lp)
                cairo_move_to(cr,xss,yss)
                cairo_line_to(cr,xs,ys)
                tck=thck
                cairo_set_line_width(cr,tck)
                cairo_set_source_rgba(cr,rgb_to_r_g_b(clr,(alp*0.1)))
                cairo_stroke(cr)
                lp = lp + 1
            until lp >= 12
            lp=0
            mark=(2*math.pi)/60
            repeat 
                xss=xc+0.84*clock_r*math.sin(mark+mark*lp)
                yss=yc-0.84*clock_r*math.cos(mark+mark*lp)
                xs=xc+1*clock_r*math.sin(mark+mark*lp)
                ys=yc-1*clock_r*math.cos(mark+mark*lp)
                cairo_move_to(cr,xss,yss)
                cairo_line_to(cr,xs,ys)
                tck=thck
                cairo_set_line_width(cr,tck)
                cairo_set_source_rgba(cr,rgb_to_r_g_b(clr,(alp*0.1)))
                cairo_stroke(cr)
                lp = lp + 1
            until lp >= 60
        -- Draw hour hand
        th=2*math.pi/hrt
            xhs=xc+0*clock_r*math.sin(hours_arc-th)
            yhs=yc-0*clock_r*math.cos(hours_arc-th)
            xh=xc+0.70*clock_r*math.sin(hours_arc-th)
            yh=yc-0.70*clock_r*math.cos(hours_arc-th)
            cairo_move_to(cr,xhs,yhs)
            cairo_line_to(cr,xh,yh)
            cairo_set_line_cap(cr,CAIRO_LINE_CAP_ROUND)
            cairo_set_line_width(cr,thck+thck*0.5)
            al=alp*0.5
            cairo_set_source_rgba(cr,rgb_to_r_g_b(clr,(al)))
            cairo_stroke(cr)
        -- Draw minute hand
        tm=(2*math.pi)/mst
            xms=xc+0*clock_r*math.sin(mins_arc-tm)
            yms=yc-0*clock_r*math.cos(mins_arc-tm)
            xm=xc+0.95*clock_r*math.sin(mins_arc-tm)
            ym=yc-0.95*clock_r*math.cos(mins_arc-tm)
            cairo_move_to(cr,xms,yms)
            cairo_line_to(cr,xm,ym)
            tk=thck/2
            cairo_set_line_width(cr,tk)
            cairo_set_source_rgba(cr,rgb_to_r_g_b(clr,(alp)))
            cairo_stroke(cr)
        -- Draw seconds hand
        if show_seconds then
            ts=(2*math.pi)/mst
                xss=xc+0*clock_r*math.sin(secs_arc-ts)
                yss=yc-0*clock_r*math.cos(secs_arc-ts)
                xs=xc+1.05*clock_r*math.sin(secs_arc-ts)
                ys=yc-1.05*clock_r*math.cos(secs_arc-ts)
                cairo_move_to(cr,xss,yss)
                cairo_line_to(cr,xs,ys)
                tck=thck/3
                cairo_set_line_width(cr,tck)
                cairo_set_source_rgba(cr,rgb_to_r_g_b(clr2,(alp))) 
                cairo_stroke(cr)
        end
    end
end
--[[ END GUAGE CLOCK WIDGET VERSION 2 ]]

--[[ RING WIDGET ]]
--[[ v1.1 by londonali1010 (2009) ]]
--[[ Options (name, arg, max, bg_colour, bg_alpha, fg_colour, fg_alpha, xc, yc, radius, thickness, start_angle, end_angle):
	"name" is the type of stat to display; you can choose from 'cpu', 'memperc', 'fs_used_perc', 'battery_used_perc'.
	"arg" is the argument to the stat type, e.g. if in Conky you would write ${cpu cpu0}, 'cpu0' would be the argument. If you would not use an argument in the Conky variable, use ''.
	"max" is the maximum value of the ring. If the Conky variable outputs a percentage, use 100.
	"bg_colour" is the colour of the base ring.
	"bg_alpha" is the alpha value of the base ring.
	"fg_colour" is the colour of the indicator part of the ring.
	"fg_alpha" is the alpha value of the indicator part of the ring.
	"x" and "y" are the x and y coordinates of the centre of the ring, relative to the top left corner of the Conky window.
	"radius" is the radius of the ring.
	"thickness" is the thickness of the ring, centred around the radius.
	"start_angle" is the starting angle of the ring, in degrees, clockwise from top. Value can be either positive or negative.
	"end_angle" is the ending angle of the ring, in degrees, clockwise from top. Value can be either positive or negative, but must be larger (e.g. more clockwise) than start_angle. ]]

function ring(name, arg, max, bgc, bga, fgc, fga, xc, yc, r, t, sa, ea)
	local function rgb_to_r_g_b(colour, alpha)
		return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
	end
	
	local function draw_ring(pct)
		local angle_0 = sa * (2 * math.pi/360) - math.pi/2
		local angle_f = ea * (2 * math.pi/360) - math.pi/2
		local pct_arc = pct * (angle_f - angle_0)

		-- Draw background ring

		cairo_arc(cr, xc, yc, r, angle_0, angle_f)
		cairo_set_source_rgba(cr, rgb_to_r_g_b(bgc, bga))
		cairo_set_line_width(cr, t)
		cairo_stroke(cr)
	
		-- Draw indicator ring

		cairo_arc(cr, xc, yc, r, angle_0, angle_0 + pct_arc)
		cairo_set_source_rgba(cr, rgb_to_r_g_b(fgc, fga))
		cairo_stroke(cr)
	end
	
	local function setup_ring()
		local str = ''
		local value = 0
		
		str = string.format('${%s %s}', name, arg)
		str = conky_parse(str)

		value = tonumber(str)
		if value == nil then value = 0 end
		pct = value/max
		
		draw_ring(pct)
	end	
	
	local updates = conky_parse('${updates}')
	update_num = tonumber(updates)
	
	if update_num > 5 then setup_ring() end
end

--[[ END RING WIDGET ]]

--[[ RING (COUNTER-CLOCKWISE) WIDGET ]]
--[[ v1.1 by londonali1010 (2009) ]]
--[[ Options (name, arg, max, bg_colour, bg_alpha, fg_colour, fg_alpha, xc, yc, radius, thickness, start_angle, end_angle):
	"name" is the type of stat to display; you can choose from 'cpu', 'memperc', 'fs_used_perc', 'battery_used_perc'.
	"arg" is the argument to the stat type, e.g. if in Conky you would write ${cpu cpu0}, 'cpu0' would be the argument. If you would not use an argument in the Conky variable, use ''.
	"max" is the maximum value of the ring. If the Conky variable outputs a percentage, use 100.
	"bg_colour" is the colour of the base ring.
	"bg_alpha" is the alpha value of the base ring.
	"fg_colour" is the colour of the indicator part of the ring.
	"fg_alpha" is the alpha value of the indicator part of the ring.
	"x" and "y" are the x and y coordinates of the centre of the ring, relative to the top left corner of the Conky window.
	"radius" is the radius of the ring.
	"thickness" is the thickness of the ring, centred around the radius.
	"start_angle" is the starting angle of the ring, in degrees, counter-clockwise from top. Value can be either positive or negative.
	"end_angle" is the ending angle of the ring, in degrees, counter-clockwise from top. Value can be either positive or negative, but must be larger (e.g. more counter-clockwise) than start_angle. ]]

function ring_ccw(name, arg, max, bgc, bga, fgc, fga, xc, yc, r, t, sa, ea)
	local function rgb_to_r_g_b(colour, alpha)
		return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
	end
	
	local function draw_ring(pct)
		local angle_0 = sa * (2 * math.pi/360) - math.pi/2
		local angle_f = ea * (2 * math.pi/360) - math.pi/2
		local pct_arc = pct * (angle_f - angle_0)

		-- Draw background ring

		cairo_arc_negative(cr, xc, yc, r, angle_0, angle_f)
		cairo_set_source_rgba(cr, rgb_to_r_g_b(bgc, bga))
		cairo_set_line_width(cr, t) 
		cairo_stroke(cr)
	
		-- Draw indicator ring

		cairo_arc_negative(cr, xc, yc, r, angle_0, angle_0 - pct_arc)
		cairo_set_source_rgba(cr, rgb_to_r_g_b(fgc, fga))
		cairo_stroke(cr)
	end
	
	local function setup_ring()
		local str = ''
		local value = 0
		
		str = string.format('${%s %s}', name, arg)
		str = conky_parse(str)
		
		value = tonumber(str)
		if value == nil then value = 0 end
		pct = value/max
		
		draw_ring(pct)
	end	
	
	local updates = conky_parse('${updates}')
	update_num = tonumber(updates)
	
	if update_num > 5 then setup_ring() end
end

--[[ END RING (COUNTER-CLOCKWISE) WIDGET ]]

function conky_widgets()
    
	if conky_window == nil then return end

    if cs == nil or cairo_xlib_surface_get_width(cs) ~= conky_window.width or cairo_xlib_surface_get_height(cs) ~= conky_window.height then
        if cs then cairo_surface_destroy(cs) end
        cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
    end
    if cr then cairo_destroy(cr) end

    cr = cairo_create(cs)

	round_rect(0, 0, 180, 568, 5, color01, 0.3)
	round_rect(5, 5, 170, 170, 10, color01, 0.3)--(x0, y0, width, height, radius, colour, alpha)
	round_rect(10, 10, 160, 160, 20, color04, 0.3)
	round_rect(5, 180, 170, 100, 10, color01, 0.3)
	round_rect(10, 185, 160, 90, 20, color04, 0.3)
	round_rect(5, 285, 170, 100, 10, color01, 0.3)
	round_rect(10, 290, 160, 90, 20, color04, 0.3)
	round_rect(5, 390, 170, 100, 10, color01, 0.3)
	round_rect(10, 395, 160, 90, 20, color04, 0.3)
	round_rect(5, 495, 170, 68, 10, color01, 0.3)
	round_rect(10, 500, 160, 58, 20, color04, 0.3)
	guage_clockv2(cr, 90, 90, 170, 1, color02, color03, 0.98, 1, 1, 2)
	printtext(90, 230, 170, color01, color02, 0.5)
    cairo_destroy(cr)
    cr = cairo_create(cs)
	ring('cpu', 'cpu0', 100, color01, 0.1, color02, 0.2, 10, 336, 37, 5, 0, 180)
	ring_ccw('memperc', '', 100, color01, 0.1, color02, 0.2, 170, 336, 37, 5, 0, 180)
	ring('battery_percent', 'BAT0', 100, color01, 0.1, color02, 0.2, 10, 441, 37, 5, 0, 180)
	ring_ccw('wireless_link_qual_perc', 'wlan0', 100, color01, 0.1, color02, 0.2, 170, 441, 37, 5, 0, 180)
    cairo_destroy(cr)
    cr = nil
end

function conky_cairo_cleanup()
    cairo_surface_destroy(cs)
    cs = nil
end
