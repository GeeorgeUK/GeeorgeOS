
-- Include this section in all plugins

if not plugins then plugins = {} end
if not commands then commands = {} end
if not global then global = {} end

-- ... Up until here

global.noPerms, global.noPerm = "§cError: §7You do not have permission"
global.disabled = "§eInfo: §7That command is disabled"

function global.spairs(tab, ord) -- Tab is table to organise, Ord is the table to use as a basis of organisation
  
  local keys = {}
  
  for key in pairs(tab) do keys[#keys+1] = key end
  
  if ord then
    table.sort(keys, function(a, b)
        return ord(t, a, b)
    end)
  else
    table.sort(keys)
  end
  
  local i = 0
  return function()
    i = i + 1
    if keys[i] then
      return keys[i], tab[keys[i]]
    end
  end
  
end

-- This section actually adds the plugin.
-- Mark as a local plugin to exclude from /plugins

plugins[ #plugins+1 ] = lukkit.addPlugin( "G-Core", "Core-1.0_5.04.2201", 
  function(plugin)
    
    plugin.onEnable( function()
        plugin.config.setDefault("enable", true) 
        plugin.config.setDefault("help.per_page", 8)
        plugin.config.setDefault("help.show_permissions", true)
        plugin.config.setDefault("help.console_shows_all", false)
        plugin.config.setDefault("help.show_descriptions", true)
        plugin.config.setDefault("help.show_commands_as_usage", false)
        plugin.config.setDefault("help.no_perms_hide", true)
        plugin.config.setDefault("help.prefix_no_permission", "§8§m")
        plugin.config.save()
        
        if plugin.config.get("enable") == true then
          plugin.print("Enabled ("..plugin.version..") Successfully")
        else
          plugin.warn("This plugin is disabled in the configuration")
        end
        
    end)
    
    plugin.onDisable( function()

        if plugin.config.get("enable") == true then
          plugin.print("Disabled ("..plugin.version..") Successfully")
        end
        
    end)
    
    if plugin.config.get("enable") == true then
      
      -- SHOW A LIST OF COMMANDS ON THE SERVER
      
      commands[#commands+1], commands.help = { 
        cmd="help",
        desc="Display's a list of commands",
        ldesc="Display a list of commands. Show advanced usage about a command by typing /help {command}",
        use="/help [page|{command}]",
        perm="g-core.help",
      }
      
      plugin.addCommand( commands.help.cmd, commands.help.desc, commands.help.use,
        function(sender, args)
          
          if sender:hasPermission(commands.help.perm) == false then
            sender:sendMessage(global.noPerm) return
          end
          
          if not args[1] then args[1] = '1' end
          
          local all = false
          if not args[1] == "all" and sender:hasPermission(commands.help.perm..".all") == true then
            all = true
          end
          
          if sender == server:getConsoleSender() and plugin.config.get("help.console_shows_all") == true then
            all = true
          end
          
          if tonumber(args[1]) == 0 and args[1] ~= "0" then
            sender:sendMessage("§f§m----------[ §cDetails of Command §7- §c/"..string.lower(commands[args[1]]).." §f]§m----------")
            return
          end
          
          local cmds = {}
          for a, b in global.spairs(commands) do
            table.insert(cmd, b)
          end
          
          local page = tonumber(args[1]) or 1
          local per_page = plugin.config.get("help.per_page") or 8
          local start = ( (per_page * ( page - 1 ) + 1 ) ) or 1
          local finish = ( per_page * page ) or 1
          local last = math.ceil( #cmds / per_page )
          
          if all == true then
            sender:sendMessage("§f&m----------§f[ §cCommand Reference §7- §cPage "..page.." of "..last.." §f]§m----------")
          elseif all == false then
            sender:sendMessage("§f§m----------§f[ §cCommand Reference §7- §cDisplaying "..#cmds.." commands §f]§m----------")
          end
          
          if all == false then
            
            if ( tonumber(page) > tonumber(lastpage) ) or ( tonumber(page) < 1 ) then
              sender:sendMessage("§7No commands were found on this page") return
            end
            
            for n = start, finish do
              if cmds[n] then
                if not cmds[n].perm or sender:hasPermission(cmds[n].perm) == true then
                  sender:sendMessage("§e/"..cmds[n].cmd.." §7"..cmds[n].desc)
                end
              else
                return
              end
            end
            
          else
            
            for n = 1, #cmds do
              if cmds[n] then
                if not cmds[n].perm or sender:hasPermission(cmds[n].perm) == true then
                  sender:sendMessage("§e/"..cmds[n].cmd.." §7"..cmds[n].desc)
                end
              else
                return
              end
            end
            
          end
          
        end
      )
      
    end
  end
)
