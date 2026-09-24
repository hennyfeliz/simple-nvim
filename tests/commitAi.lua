vim.opt.runtimepath:prepend('C:/Users/henny/AppData/Local/nvim')
local m = require('commitAi')
local t = m._test
local function check(value, message) assert(value, message) end
local good = vim.json.encode({summary='feat: improve local development commands',description='- Add reusable development commands for local workflows.\n- Consolidate shared configuration for those commands.'})
check(t.validate(good), 'valid message rejected')
check(t.validate(vim.json.encode({summary='fix: correct addition logic',description={'Replace subtraction with addition in the add function.'}})), 'bullet array rejected')
check(not t.validate(vim.json.encode({summary='fix: correct addition logic',description={5}})), 'nonstring bullet accepted')
check(t.validate('```json\n'..good..'\n```'), 'valid fenced JSON rejected')
check(not t.validate(vim.json.encode({summary='feat: x',description=''})), 'empty body accepted')
check(not t.validate(vim.json.encode({summary='feat: '..string.rep('x',80),description=string.rep('x',50)})), 'long title accepted')
check(not t.validate(vim.json.encode({summary='random: invalid title',description=string.rep('x',50)})), 'invalid type accepted')
check(not t.validate('not json'), 'invalid JSON accepted')
local file1 = 'diff --git a/a b/a\n'..string.rep('+hello world\n',100)
local file2 = 'diff --git a/b b/b\n'..string.rep('+hola mundo\n',100)
check(#t.split_text(file1..file2)==1, 'small files not grouped')
local chunks=t.split_text('diff --git a/big b/big\n'..string.rep('+á你好\n',20000))
for _,chunk in ipairs(chunks) do
 check(#chunk<=t.max_chunk_bytes, 'oversized chunk')
 check(not chunk:find('\239\191\189',1,true), 'replacement character')
 check(chunk:find('diff --git a/big b/big',1,true), 'filename lost')
end
-- Simula el transporte; comprueba el flujo completo sin GPU ni clipboard real.
local original_system, original_writefile = vim.system, vim.fn.writefile
vim.fn.writefile = function() return 0 end
local outputs, copied, notice, unloaded, calls, fail_copy, fail_unload
vim.fn.setreg = function(_, message)
    if fail_copy then error('clipboard unavailable') end
    copied = message
    return 0
end
vim.notify = function(message) notice = message end
m.read_diff = function() return file1 end
vim.system = function(command, options, callback)
    if command[1] == 'git' then
        return { wait = function() return {code=0,stdout='C:/repo',stderr=''} end }
    end
    local payload=vim.json.decode(options.stdin)
    local result
    if payload.keep_alive == 0 then
        unloaded = true
        result = fail_unload and {code=1,stdout='',stderr='unload failed'}
            or {code=0,stdout=vim.json.encode({done=true}),stderr=''}
    else
        calls = calls + 1
        check(payload.think == false, 'thinking enabled')
        check(payload.format.required[2] == 'description', 'missing required description')
        local response=table.remove(outputs,1)
        if response == 'network_error' then result={code=1,stdout='',stderr='offline'}
        else result={code=0,stdout=vim.json.encode({done=true,done_reason='stop',message={content=response}}),stderr=''} end
    end
    vim.schedule(function() callback(result) end)
end
local function run(responses)
    outputs, copied, notice, unloaded, calls = responses, nil, nil, false, 0
    m.generate('staged')
    check(vim.wait(2000,function() return notice~=nil end,10), 'mock timed out')
    check(unloaded, 'model not unloaded')
end
run({good})
check(copied and copied:find('\n\n',1,true), 'title/body not separated')
check(calls==1 and m.last_metrics.status=='ok', 'small diff should need one call')
run({'{}',good})
check(copied and calls==2, 'repair failed')
run({'{}','{}'})
check(not copied and calls==2 and m.last_metrics.status=='error', 'invalid answer accepted or retried indefinitely')
run({'network_error'})
check(not copied and calls==1, 'transport error not handled')
fail_copy=true
run({good})
check(m.last_metrics.status=='error', 'clipboard failure not recorded')
fail_copy=false
fail_unload=true
run({good})
check(m.last_metrics.status=='error', 'unload failure not recorded')
vim.system, vim.fn.writefile = original_system, original_writefile
print('PASS: validation, UTF-8 splitting, one-call generation, bounded repair, network/clipboard/unload errors')
vim.cmd('qa!')
