local vgui_sys = ffi.cast(ffi.typeof("void***"), utils.find_interface("vgui2.dll", "VGUI_System010"))
local native_GetClipboardTextCount = ffi.cast("int(__thiscall*)(void*)", vgui_sys[0][7])
local native_SetClipboardText = ffi.cast("void(__thiscall*)(void*, const char*, int)", vgui_sys[0][9])
local native_GetClipboardText = ffi.cast("int(__thiscall*)(void*, int, const char*, int)", vgui_sys[0][11])
local new_char_arr = ffi.typeof("char[?]")

local event_funcs = setmetatable({},{
    __index = function(tbl,key)
        local newEvent = {}
        tbl[key] = newEvent
        return newEvent
    end
})
local events = setmetatable({}, {
    __index = function(tbl, key)
        local newEvent = { set = function(self, func)
            table.insert(event_funcs[key],func);
        end }
        tbl[key] = newEvent
        return newEvent
    end
})
printtable = function(table)
    print("Table : "..utils.json_encode(table))
end



local ui = {
    group = function(container)
        return {
            checkbox = function(self,name)
                local obj = gui.add_checkbox(name,container)
                local vis_cond = false
                local path = container..">"..name
                local funnies = {
                    get = function(self)
                        return obj:get_bool()
                    end,
                    set = function(self,val)
                        if type(val) == "boolean" then
                            return obj:set_bool(val)
                        else
                            return obj:set_bool(val == 1)
                        end
                    end,
                    type = function(self)
                        return "checkbox"
                    end,
                    visibility = function(self,condition)
                        if condition == nil then
                            return vis_cond 
                        end
                        vis_cond = condition
                        gui.set_visible(path, vis_cond)
                    end,
                    colorpicker = function(self,color,bar)
                        if bar == nil then bar = true end
                        if color == nil then color = render.color(255,255,255,255) end
                        local obj = gui.add_colorpicker(path,bar,color)
                        local funnies = {
                            type = function(self)
                                return "colorpicker"
                            end,
                            get = function(self)
                                return obj:get_color()
                            end,
                            set = function(self,color)
                                obj:set_color(color)
                            end
                        }
                        return funnies
                    end,
                    bind = function(self)
                        local obj = gui.add_keybind(path)
                    end
                }
                return funnies
            end,
            slider = function(self,name,min,max,scale)
                if scale == nil then scale = 1 end
                local obj = gui.add_slider(name, container, min, max, scale)
                local vis_cond = false
                local funnies = {
                    get = function(self)
                        return obj:get_float()
                    end,
                    set = function(self,val)
                        return obj:set_float(val)
                    end,
                    type = function(self)
                        return "slider"
                    end,
                    visibility = function(self,condition)
                        if condition == nil then
                            return vis_cond 
                        end
                        vis_cond = condition
                        gui.set_visible(container..">"..name, vis_cond)
                    end
                }
                return funnies
            end,
            combo = function(self,name,...)
                local _t = {...}
                if type(_t[1]) == "table" then _t = _t[1] end
                local obj = gui.add_combo(name,container,_t)
                local vis_cond = false
                local funnies = {
                    get = function(self,index)
                        if index== nil then return obj:get_int() end
                        return index == obj:get_int()+1
                    end,
                    set = function(self,index)
                        obj:set_int(index)
                    end,
                    type = function(self)
                        return "combobox"
                    end,
                    visibility = function(self,condition)
                        if condition == nil then
                            return vis_cond 
                        end
                        vis_cond = condition
                        gui.set_visible(container..">"..name, vis_cond)
                    end
                }
                return funnies
            end,
            multicombo = function(self,name,...)
                local _t = {...}
                if type(_t[1]) == "table" then _t = _t[1] end
                local obj = {gui.add_multi_combo(name,container,_t)}
                local vis_cond = false
                local funnies = {
                    get = function(self,index)
                        for k,v in pairs(obj) do
                            if k == index then return v:get_bool() end
                        end
                        return false
                    end,
                    multiget = function(self)
                        local _t = {}
                        for k,v in pairs(obj) do
                            _t[k] = v:get_bool() 
                        end
                        return _t
                    end,
                    set = function(self,val)
                        for k,v in pairs(obj) do
                            if k == val then 
                                v:set_bool(true)
                            else
                                v:set_bool(false)
                            end 
                        end
                    end,
                    multiset = function(self,val)
                        for k,v in pairs(obj) do
                            if val[k] == nil then val[k] = 0 end
                            v:set_bool(val[k] == true or val[k] == 1)
                        end
                    end,
                    type = function(self)
                        return "multicombo"
                    end,
                    visibility = function(self,condition)
                        if condition == nil then
                            return vis_cond 
                        end
                        vis_cond = condition
                        gui.set_visible(container..">"..name, vis_cond)
                    end,
                    colorpicker = function(self,color,bar)
                        if bar == nil then bar = true end
                        if color == nil then color = render.color(255,255,255,255) end
                        local obj = gui.add_colorpicker(container..">"..name,bar,color)
                        local funnies = {
                            type = function(self)
                                return "colorpicker"
                            end,
                            get = function(self)
                                return obj:get_color()
                            end,
                            set = function(self,color)
                                obj:set_color(color)
                            end
                        }
                        return funnies
                    end
                }
                return funnies
            end,
            button = function(self,name,callback)
                local functions = {callback}
                gui.add_button(name, container, function() 
                    for k,v in pairs(functions) do
                        v()
                    end
                end)
                local vis_cond = false
                local funnies = {
                    add = function(self,callback)
                        table.insert(functions,callback)
                    end,
                    type = function(self)
                        return "button"
                    end,
                    visibility = function(self,condition)
                        if condition == nil then
                            return vis_cond 
                        end
                        vis_cond = condition
                        gui.set_visible(container..">"..name, vis_cond)
                    end
                }
                return funnies

            end,
            input = function(self,name)
                local obj = gui.add_textbox(name, container)
                local vis_cond = false
                local funnies = {
                    get = function(self)
                        return obj:get_string()
                    end,
                    set = function(self,val)
                        obj:set_string(val)
                    end,
                    type = function(self)
                        return "text"
                    end,
                    visibility = function(self,condition)
                        if condition == nil then
                            return vis_cond 
                        end
                        vis_cond = condition
                        gui.set_visible(container..">"..name, vis_cond)
                    end
                }
                return funnies
            end,
            list = function(self,name,lenght,search,...)
                local obj = gui.add_listbox(name,container,lenght,search,...)
                local vis_cond = false
                local funnies = {
                    get = function(self,index)
                        return index == obj:get_int()+1
                    end,
                    set = function(self,index)
                        obj:set_int(index-1)
                    end,
                    type = function(self)
                        return "listbox"
                    end,
                    visibility = function(self,condition)
                        if condition == nil then
                            return vis_cond 
                        end
                        vis_cond = condition
                        gui.set_visible(container..">"..name, vis_cond)
                    end
                }
                return funnies
            end,

        } --inside joke 🪑🪑🪑🪑
    end,
    export = function(table)
        local _t = {}
        for k,v in pairs(table) do
            if v:type() == "button" then goto continue end
            if v:type() == "multicombo" then
                _t[k] = v:multiget()
            else
                _t[k] = v:get()
            end
            ::continue::
        end
        return utils.json_encode(_t) 
    end,
    import = function(table,string)
        local _t = utils.json_decode(utils.base64_decode(string))
        for k,v in pairs(table) do
            if k == "button" then goto continue end
            for k2,v2 in pairs(_t) do
                if k == k2 then
                    if v:type() == "multicombo" then
                        v:multiset(v2)
                    elseif v:type() == "color" then
                        local c = render.color(v2.r,v2.g,v2.b,v2.a)
                        v:set(c)
                    else
                        v:set(v2)
                    end
                end
            end
            ::continue::
        end
    end,
    format = function(t, ...) 
        local str = ""
        for _, word in ipairs({...}) do
            str = string.format("%s%s", str, word)
        end
        local templ = t(str);
        
        if templ == 0 then
            return str
        else
            return templ 
        end
    end

}


local anims = {
    lerp = function(a,b,t)
        return a + (a-b)*t
    end
}

local vector = {}

vector.new = function(x,y,z)
    return setmetatable({x=x,y=y,z=z},{__index = vector})
end

function vector:lenght()
    return math.sqrt(self.x^2 + self.y^2 + self.z^2)
end

function vector:distance(vec2)
    diff = vector.new(self.x-vec2.x,self.y-vec2.y,self.z-vec2.z)
    return diff:lenght()
end

function vector:lerp(vec,mod)
    local x = self.x
    local y = self.y
    local z = self.z
    x = anims.lerp(x,vec.x,mod)
    y = anims.lerp(y,vec.y,mod)
    z = anims.lerp(z,vec.z,mod)
    return vector.new(x,y,z)
end

local _render = {}
_render.screen_size = function()
    return vector.new(render.get_screen_size(),0)
end

local _G = {
    clipboard = {
        get = function(self)
            local len = native_GetClipboardTextCount(vgui_sys)
            if len > 0 then
                local char_arr = new_char_arr(len)
                native_GetClipboardText(vgui_sys, 0, char_arr, len)
                return ffi.string(char_arr, len-1)
            end
        end,
        set = function(self,text)
            local text = tostring(text)
            native_SetClipboardText(vgui_sys, text, string.len(text))
        end
    },
    events = events,
    ui = ui,
    vector = vector
}

function on_paint()
    for _,func in pairs(event_funcs.on_paint) do
        func()
    end
end

function on_paint_traverse()
    for _,func in pairs(event_funcs.on_paint_traverse) do
        func()
    end
end

function on_frame_stage_notify(stage, pre_original)
    for _,func in pairs(event_funcs.on_frame_stage_notify) do
        func(stage,pre_original)
    end
end

function on_setup_move(cmd)
    for _,func in pairs(event_funcs.on_setup_move) do
        func(cmd)
    end
end

function on_run_command(cmd)
    for _,func in pairs(event_funcs.on_run_command) do
        func(cmd)
    end
end

function on_create_move(cmd, send_packet)
    for _,func in pairs(event_funcs.on_create_move) do
        func(cmd,send_packet)
    end
end

function on_input(msg, wParam, lParam)
    for _,func in pairs(event_funcs.on_input) do
        func(msg, wParam, lParam)
    end
end

function on_console_input(input)
    for _,func in pairs(event_funcs.on_console_input) do
        func(input)
    end
end

function on_shutdown()
    for _,func in pairs(event_funcs.on_shutdown) do
        func(input)
    end
end

function on_shot_registered(shot_info)
    for _,func in pairs(event_funcs.on_shot_registered) do
        func(shot_info)
    end
end

function on_level_init()
    for _,func in pairs(event_funcs.on_level_init) do
        func(shot_info)
    end
end

function on_do_post_screen_space_events()
    for _,func in pairs(event_funcs.on_do_post_screen_space_events) do
        func()
    end
end

function on_config_load()
    for _,func in pairs(event_funcs.on_config_load) do
        func()
    end
end

function on_config_save()
    for _,func in pairs(event_funcs.on_config_save) do
        func()
    end
end

function on_esp_flag(index)
    for _,func in pairs(event_funcs.on_esp_flag) do
        func(index)
    end
end

function on_draw_model_execute(dme, ent_index, model_name)
    for _,func in pairs(event_funcs.on_draw_model_execute) do
        func(dme, ent_index, model_name)
    end
end

function on_game_event(event)
    for k,v in pairs(events) do
        if event:get_name() == tostring(k) then
            for _,func in pairs(event_funcs[tostring(k)]) do
                func()
            end
        end
    end
end

return _G