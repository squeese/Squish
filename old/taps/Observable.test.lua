local test = require 'gambiarra'
local Observable = require 'Observable'
local Packer = require 'Packer'

table.wipe = function(tbl)
  for key in pairs(tbl) do
    tbl[key] = nil
  end
  setmetatable(tbl, nil)
end

test('Observable.create', function()
  do
    local unsub = spy()
    local tmp = Observable
      .create(function(send, done)
        return unsub
      end)
      :subscribe()
    tmp()
    ok(unsub ~= Observable.identity, 'returned cleanup function should not be identity when providing one')
    ok(#unsub.called == 1, 'provided unsub fn should be called when unsubbing')
  end
  do
    local unsub = Observable.create(function() end):subscribe()
    ok(unsub == Observable.ident, 'not returning an cleanup function should return identity')
    ok(pcall(unsub), 'not returning a cleanup function and calling it, should not fail')
  end
end)

test('Observable.of', function()
  do
    local send = spy()
    local done = spy()
    local unsub = Observable.of(1, 2, 3):subscribe(send, done)
    ok(#send.called == 3, 'read called three times')
    ok(#done.called == 1, 'done called once')
    ok(eq(send.called[1], {1}), 'read 1')
    ok(eq(send.called[2], {2}), 'read 2')
    ok(eq(send.called[3], {3}), 'read 3')
    ok(pcall(unsub), 'calling unsub should not fail')
  end
  do
    collectgarbage('collect')
    local before = collectgarbage('count')
    do
      local Stream = Observable.of(1, 2, 3)
      for i = 1, 100 do
        Stream:subscribe()()
      end
    end
    collectgarbage('collect')
    ok(before == collectgarbage('count'), 'shouldnt leak memory')
  end
end)

test('Observable.just', function()
  do
    local send = spy()
    local done = spy()
    local unsub = Observable.just(1, 2, 3):subscribe(send, done)
    ok(#send.called == 1, 'read called once')
    ok(#done.called == 1, 'done called once')
    ok(eq(send.called[1], {1,2,3}), 'read 1, 2, 3')
    ok(pcall(unsub), 'calling unsub should not fail')
  end
  do
    collectgarbage('collect')
    local before = collectgarbage('count')
    do
      local Stream = Observable.just(1, 2, 3):map()
      for i = 1, 100 do
        Stream:subscribe()()
      end
    end
    collectgarbage('collect')
    ok(before == collectgarbage('count'), 'shouldnt leak memory')
  end
end)

test('Observable:map', function()
  do
    local map = spy(function(v)
      return v*v
    end)
    local send = spy()
    Observable.of(1, 2, 3):map(map):subscribe(send)
    ok(#map.called == 3, 'map called three times')
    ok(eq(map.called[1], {1}), 'map called with 1')
    ok(eq(map.called[2], {2}), 'map called with 2')
    ok(eq(map.called[3], {3}), 'map called with 3')
    ok(eq(send.called[1], {1}), 'send read result 1')
    ok(eq(send.called[2], {4}), 'send read result 2')
    ok(eq(send.called[3], {9}), 'send read result 9')
  end
  do
    local send = spy()
    Observable.of({1, 2, 3}):map(unpack):subscribe(send)
    ok(eq(send.called[1], {1, 2, 3}), 'can return many values')
  end
  do
    local send = spy()
    Observable.of({1, 2}, {3, 4})
      :map(unpack)
      :map(function(a, b)
        return a+b
      end)
      :subscribe(send)
    ok( eq(send.called[1], {3})
    and eq(send.called[2], {7}),
      'can read many arguments')
  end
  do
    local send = spy()
    Observable.of(1):map():subscribe(send)
    ok(eq(send.called[1], {1}), 'no fn provided should use identity')
  end
  do
    collectgarbage('collect')
    local before = collectgarbage('count')
    do
      local Stream = Observable.of(1, 2, 3):map()
      for i = 1, 100 do
        Stream:subscribe()()
      end
    end
    collectgarbage('collect')
    ok(before == collectgarbage('count'), 'shouldnt leak memory')
  end
end)

test('Observable:filter', function()
  do
    local send = spy()
    Observable.of(1, 2, 3, 4, 5)
      :filter(function(v)
        return math.fmod(v, 2) == 0
      end)
      :subscribe(send)
    ok( eq(send.called[1], {2})
    and eq(send.called[2], {4}),
      'should filter for even numbers')
  end
  do
    local send = spy()
    Observable.of(1, false, 3):filter():subscribe(send)
    ok( eq(send.called[1], {1})
    and eq(send.called[2], {3}),
      'no fn provided should use identity')
  end
  do
    collectgarbage('collect')
    local before = collectgarbage('count')
    do
      local Stream = Observable.of(1, 2, 3):filter()
      for i = 1, 100 do
        Stream:subscribe()()
      end
    end
    collectgarbage('collect')
    ok(before == collectgarbage('count'), 'shouldnt leak memory')
  end
end)

test('Observable:take', function()
  do
    local send = spy()
    local done = spy()
    Observable
      .create(function(send, done)
        for i = 1, 2 do
          send(1)
          send(2)
          send(3)
          done()
        end
      end)
      :take(2)
      :subscribe(send, done)
    ok(#send.called == 4, 'send called four times')
    ok(#done.called == 2, 'done called two times')
    ok( eq(send.called[1], {1})
    and eq(send.called[2], {2})
    and eq(send.called[3], {1})
    and eq(send.called[4], {2}),
      'should only read 1, 2 then 1, 2 again')
  end
  do
    collectgarbage('collect')
    local before = collectgarbage('count')
    do
      local Stream = Observable.of(1, 2, 3):take(2)
      for i = 1, 100 do
        Stream:subscribe()()
      end
    end
    collectgarbage('collect')
    ok(before == collectgarbage('count'), 'shouldnt leak memory')
  end
end)

test('Observable:collect', function()
  do
    local send = spy()
    local done = spy()
    Observable.of(1, 2, 3):collect():subscribe(send, done)
    ok(#send.called == 1, 'send called once')
    ok(#done.called == 1, 'done called once')
    ok(eq(send.called[1], {1, 2, 3}), 'send should read {1, 2, 3}')
  end
  do
    local send = spy()
    local done = spy()
    Observable
      .create(function(send)
        send(1)
        send(2)
        send(3)
      end)
      :collect()
      :subscribe(send, done)
    ok(not send.called, 'send shouldnt have been called')
    ok(not done.called, 'done shouldnt have been called')
  end
  do
    collectgarbage('collect')
    local before = collectgarbage('count')
    do
      local Stream = Observable.of(1, 2, 3):collect()
      for i = 1, 100 do
        Stream:subscribe()()
      end
    end
    collectgarbage('collect')
    ok(before == collectgarbage('count'), 'shouldnt leak memory')
  end
end)

test('Observable:switch', function()
  do
    local a = Observable.create(function(send, done)
      send(1)
      send(2)
      send(3)
      done()
    end)
    local b = Observable.create(function(send, done)
      send(4)
      send(5)
      send(6)
      done()
    end)
    local read = spy()
    local done = spy()
    Observable.of(a, b):switch():subscribe(read, done)
    ok(#read.called == 6, 'read should be called six times')
    ok(#done.called == 2, 'done should be called two times')
    ok( eq(read.called[1], {1})
    and eq(read.called[2], {2})
    and eq(read.called[3], {3})
    and eq(read.called[4], {4})
    and eq(read.called[5], {5})
    and eq(read.called[6], {6}),
      'should read values from streams in order provided')
  end
  do
    local send = spy()
    local done = spy()
    local outerUnsub = spy()
    local innerUnsub = spy()
    local unsub = Observable
      .create(function(send, done)
        for i = 1, 3 do
          send(Observable.create(function(send, done)
            send(i..1)
            send(i..2)
            send(i..3)
            done()
            return innerUnsub
          end))
        end
        done()
        return outerUnsub
      end)
      :switch()
      :subscribe(send, done)
    unsub()

    ok(#outerUnsub.called == 1, 'outerUnsub should be called one time')
    ok(#innerUnsub.called == 3, 'innerUnsub should be called three times')
    ok(#done.called == 3, 'done should be called three times')
  end
  do
    collectgarbage('collect')
    local before = collectgarbage('count')
    do
      local a = Observable.of(1, 2, 3)
      local b = Observable.of(4, 5, 6)
      local Stream = Observable.of(a, b):switch()
      for i = 1, 100 do
        Stream:subscribe()()
      end
    end
    collectgarbage('collect')
    ok(before == collectgarbage('count'), 'shouldnt leak memory #1')
  end
  do
    collectgarbage('collect')
    local before = collectgarbage('count')
    do
      local Stream = Observable
        .create(function(send, done)
          for i = 1, 3 do
            send(Observable.create(function(send, done)
              send(i..1)
              send(i..2)
              send(i..3)
              done()
            end))
          end
        end)
        :switch()
      for i = 1, 100 do
        Stream:subscribe()()
      end
    end
    collectgarbage('collect')
    ok(before == collectgarbage('count'), 'shouldnt leak memory #2')
  end
end)

test('Observable:startWith', function()
  do
    local send = spy()
    Observable.of('c', 'd')
      :startWith('b')
      :map(string.upper)
      :startWith('A')
      :subscribe(send)
    ok(#send.called == 4, 'send should be called four times')
    ok( eq(send.called[1], {'A'})
    and eq(send.called[2], {'B'})
    and eq(send.called[3], {'C'})
    and eq(send.called[4], {'D'}),
      'should read values in correct order')
  end
  do
    local send = spy()
    Observable.just('c', 'd'):startWith('a', 'b'):subscribe(send)
    ok( eq(send.called[1], {'a', 'b'})
    and eq(send.called[2], {'c', 'd'}),
      'should be able to send multiple values')
  end
  do
    collectgarbage('collect')
    local before = collectgarbage('count')
    do
      local Stream = Observable.of(1, 2, 3):startWith(-1, -2, -3)
      for i = 1, 100 do
        Stream:subscribe()()
      end
    end
    collectgarbage('collect')
    ok(before == collectgarbage('count'), 'shouldnt leak memory')
  end
end)

test('Observable:expand', function()
  local send = spy()
  local Stream = Observable.of(1, 2, 3)
    :expand(function(send, done, ...)
      local function onSend(v)
        send(v * v)
      end
      return onSend, done, ...
    end)
  Stream:subscribe(send)
  ok(#send.called, 'send should be called three times')
  ok( eq(send.called[1], {1})
  and eq(send.called[2], {4})
  and eq(send.called[3], {9}),
    'should return correct values')

  collectgarbage('collect')
  local before = collectgarbage('count')
  do
    for i = 1, 100 do
      Stream:subscribe()()
    end
  end
  collectgarbage('collect')
  ok(before == collectgarbage('count'), 'shouldnt leak memory')
end)

test('Packer', function()
  do
    local pack = Packer.create(3)
    pack(1, 'a')
    pack(2, 'b')
    pack(3, 'c')
    ok(pack:isPending() == false, 'should not be pending')
    ok(eq({unpack(pack)}, {'a', 'b', 'c'}), 'should match one value for each slot')
    ok(not pcall(pack, 4, 'd'), 'should fail writing out of bounds')
    ok(not pcall(Packer.create), 'should fail creating packer without size')
    ok(#pack.__offsets == 3, 'size should be three')
  end
  do
    local pack = Packer.create(3)
    pack(1, 'a')
    pack(2)
    pack(3, 'c')
    ok(pack:isPending() == false, 'should not be pending')
    ok(eq({unpack(pack)}, {'a', 'c'}), 'should match with one value as nil')
  end
  do
    local pack = Packer.create(3, true)
    pack(1, 'a')
    pack(3, 'b')
    ok(pack:isPending() == true, 'should be pending with missing write')
  end
  do
    local pack = Packer.create(3)
    pack(1, 'a')
    pack(3, 'b')
    ok(pack:isPending() == false, 'should not be pending with missing write, since not usePending flagged')
    ok(eq({unpack(pack)}, {'a', 'b'}), 'should match values')
  end
  do
    local pack = Packer.create(3)
    local changed
    pack(1)
    pack(2, 'b1', 'b2')
    pack(3, 'c1')
    ok(eq({unpack(pack)}, {'b1', 'b2', 'c1'}), 'should match values')
    changed = pack(1, 'a1', 'a2')
    ok(eq({unpack(pack)}, {'a1', 'a2', 'b1', 'b2', 'c1'}), 'should match values, after write mutations #1')
    ok(changed == true, 'changed should return true #1')
    changed = pack(2)
    ok(changed == true, 'changed should return true #2')
    changed = pack(3)
    ok(changed == true, 'changed should return true #3')
    changed = pack(3)
    ok(changed == false, 'changed should return false #4')
    ok(eq({unpack(pack)}, {'a1', 'a2'}), 'should match values, after write mutations #2')
    changed = pack(3, 'c1', 'c2', 'c3')
    ok(changed == true, 'changed should return true #5')
    changed = pack(3, 'c1', 'c2', 'c3')
    ok(changed == false, 'changed should return false #6')
    ok(eq({unpack(pack)}, {'a1', 'a2', 'c1', 'c2', 'c3'}), 'should match values, after write mutations #3')
  end
  do
    collectgarbage('collect')
    local before = collectgarbage('count')
    do
      local tmp = {}
      for iteration = 1, 100 do
        local size = math.random(10)
        local p = Packer.create(size)
        for slot = 1, size do
          table.wipe(tmp)
          for col = 1, math.random(3) do
            tmp[col] = math.random()
          end
          p(slot, unpack(tmp))
        end
      end
    end
    collectgarbage('collect')
    ok(before == collectgarbage('count'), 'shouldnt leak memory')
  end
end)

test('Observable.combineLatest', function()
  do
    local send = spy()
    local a = Observable.of(1, 2, 3)
    local b = Observable.just('a', 'b', 'c')
    local c = Observable.of(4, 5, 6)
    Observable.combineLatest(a, b, c):subscribe(send)
    ok(#send.called == 3, 'send should be called three times')
    ok( eq(send.called[1], {3, 'a', 'b', 'c', 4})
    and eq(send.called[2], {3, 'a', 'b', 'c', 5})
    and eq(send.called[3], {3, 'a', 'b', 'c', 6}),
      'should match values')
  end
  do
    collectgarbage('collect')
    local before = collectgarbage('count')
    do
      local a = Observable.of(1, 2, 3)
      local b = Observable.just('a', 'b', 'c')
      local c = Observable.of(4, 5, 6)
      local Stream = Observable.combineLatest(a, b, c)
      for i = 1, 100 do
        Stream:subscribe()()
      end
    end
    collectgarbage('collect')
    local after = collectgarbage('count')
    ok(before == after, 'shouldnt leak memory')
  end
end)

test('Observable:bind', function()
  do
    local send = spy()
    local root = Observable.create(function(send, _, ctx)
      send('CTX='..ctx)
    end)
    root:subscribe(send, nil, 'ROOT')
    ok(eq(send.called[1], {'CTX=ROOT'}), 'value should be composite of passed ctx')

    send = spy()
    root
      :bind('BOUND#1')
      :bind('BOUND#2')
      :subscribe(send, nil, 'ROOT')
    ok(eq(send.called[1], {'CTX=BOUND#1'}), 'value should be composite of first bound ctx')

    send = spy()
    Observable
      .create(function(send, _, ...)
        local ctx = ''
        for i = 1, select('#', ...) do
          ctx = ctx..select(i, ...)
        end
        send(ctx)
      end)
      :subscribe(send, nil, 'c', 't', 'x')
    ok(eq(send.called[1], {'ctx'}), 'value should be string \'ctx\'')
  end
  do
    collectgarbage('collect')
    local before = collectgarbage('count')
    do
      local Stream = Observable.of(1, 2, 3):bind('a', 'b', 'c')
      for i = 1, 100 do
        Stream:subscribe()()
      end
    end
    collectgarbage('collect')
    local after = collectgarbage('count')
    ok(before == after, 'shouldnt leak memory')
  end
end)