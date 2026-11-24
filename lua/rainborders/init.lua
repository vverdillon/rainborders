local M = {}

local default_colors = {
    "#456ABA",
    "#9145BA",
    "#C23E9E",
    "#B53C3C",
    "#D17728",
    "#DEDE47",
    "#80C458",
    "#58C4BD",
}

local function split_str(inputstr, sep)
    sep = sep or "%s"
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

local function ensure_cache_dir()
    local cache_path = vim.fn.stdpath("cache") .. "/rainborders"
    local instances_path = cache_path .. "/instances"

    if vim.fn.isdirectory(cache_path) == 0 then
        vim.fn.mkdir(cache_path, "p")
    end

    local f = io.open(instances_path, "a+")
    if f then
        f:close()
    end

    return instances_path
end

local function next_instance_number(instances_path, current_pid)
    local active_instances = {}
    local active_instances_nb = {}

    local f_read = io.open(instances_path, "r")
    if f_read then
        for line in f_read:lines() do
            local line_split = split_str(line, " ")
            local pid = tonumber(line_split[1])
            local nb = tonumber(line_split[2])

            if pid and pid ~= current_pid then
                local ok, alive = pcall(vim.uv.kill, pid, 0)
                if ok and alive then
                    table.insert(active_instances, { pid, nb })
                    table.insert(active_instances_nb, nb)
                end
            end
        end
        f_read:close()
    end

    table.sort(active_instances_nb)
    local num_instance = 1
    while num_instance == active_instances_nb[num_instance] do
        num_instance = num_instance + 1
    end

    table.insert(active_instances, { current_pid, num_instance })

    local f_write = io.open(instances_path, "w")
    if f_write then
        for _, pid_nb in ipairs(active_instances) do
            f_write:write(pid_nb[1] .. " " .. pid_nb[2] .. "\n")
        end
        f_write:close()
    end

    return num_instance
end

function M.setup(opts)
    opts = opts or {}
    local colors = opts.colors or default_colors
    local num_colors = #colors
    if num_colors == 0 then
        return
    end

    local instances_path = ensure_cache_dir()
    local current_pid = vim.fn.getpid()
    local num_instance = next_instance_number(instances_path, current_pid)

    vim.api.nvim_set_hl(0, "VerticalBar", { fg = colors[(num_instance - 1) % num_colors + 1], bg = "none" })
    vim.o.statuscolumn = "%#VerticalBar#█%*%s%l "
end

return M
