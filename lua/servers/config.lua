-- Table to keep track of server jobs
local servers = {
  springboot = { job_id = nil, cmd = "mvn spring-boot:run" },
  quarkus = { job_id = nil, cmd = "quarkus dev" },
  react = { job_id = nil, cmd = "npm start" },
}

local function start_server(server_name)
  local server = servers[server_name]
  if not server then
    print("Unknown server: " .. server_name)
    return
  end
  if server.job_id then
    print(server_name .. " server is already running!")
    return
  end
  server.job_id = vim.fn.jobstart(server.cmd, {
    on_exit = function(_, code)
      if code ~= 0 then
        print(server_name .. " server exited with code " .. code)
      end
      server.job_id = nil
      vim.cmd("redrawstatus")
    end,
  })
  print(server_name .. " server started.")
  vim.cmd("redrawstatus")
end

local function stop_server(server_name)
  local server = servers[server_name]
  if not server then
    print("Unknown server: " .. server_name)
    return
  end
  if not server.job_id then
    print(server_name .. " server is not running!")
    return
  end
  vim.fn.jobstop(server.job_id)
  server.job_id = nil
  print(server_name .. " server stopped.")
  vim.cmd("redrawstatus")
end

-- Create Neovim commands
vim.api.nvim_create_user_command("StartSpringBoot", function()
  start_server("springboot")
end, {})

vim.api.nvim_create_user_command("StopSpringBoot", function()
  stop_server("springboot")
end, {})

vim.api.nvim_create_user_command("StartReact", function()
  start_server("react")
end, {})

vim.api.nvim_create_user_command("StopReact", function()
  stop_server("react")
end, {})

vim.api.nvim_create_user_command("StartQuarkus", function()
  start_server("quarkus")
end, {})

vim.api.nvim_create_user_command("StopQuarkus", function()
  stop_server("quarkus")
end, {})

-- Similarly, create commands for quarkus, react, etc.
