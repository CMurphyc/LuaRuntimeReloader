
local EC = EC and EC or {}

local function paramcheck(_x)
	if _x and type(_x) ~= "number"  then error(debug.traceback("Vector3Check",2)) end
end

---@class Vector3

---@alias UnityEngine.Vector3 Vector3

EC.Vector3 = {
  ---@return Vector3
  new = function( _x, _y, _z)
  	--paramcheck(_x)
  	--paramcheck(_y)
  	--paramcheck(_z)
    local ret = { x = _x or 0, y = _y or 0, z = _z or 0 }
    setmetatable(ret,EC.Vector3)
    return ret
  end,
  
  __add = function (lhs,rhs)
    local ret = { x = lhs.x + rhs.x, y = lhs.y + rhs.y, z = lhs.z + rhs.z }
    setmetatable(ret,EC.Vector3)
    return ret
  end,


  __sub = function ( lhs, rhs )
    local ret = { x = lhs.x - rhs.x, y = lhs.y - rhs.y, z = lhs.z - rhs.z }
    setmetatable(ret,EC.Vector3)
    return ret
  end,

  -- __mul = function( lhs, factor)
  --   local ret = { x = lhs.x * factor, y = lhs.y * factor, z = lhs.z * factor }
  --   setmetatable(ret, EC.Vector3)
  --   return ret
  -- end,
  -- 下面稍微改了一下 by zzy At 21.8.19，让Vector3也可以支持左乘
  __mul = function( lhs, rhs )
    local ret = nil
    if type(rhs) == "number" then
      ret = { x = lhs.x * rhs, y = lhs.y * rhs, z = lhs.z * rhs }
    elseif type(lhs) == "number" then
      ret = { x = lhs * rhs.x, y = lhs * rhs.y, z = lhs * rhs.z }
    end
    setmetatable(ret, EC.Vector3)
    return ret
  end,

  __div = function( lhs, div )
  	--paramcheck(div)
    return EC.Vector3.__mul(lhs, 1/div)
  end,

  __unm = function( lhs )
    local ret = { x = -lhs.x, y = -lhs.y, z = -lhs.z }
    setmetatable(ret, EC.Vector3)
    return ret
  end,

  __len = function( lhs )
    local len = lhs.x*lhs.x + lhs.y*lhs.y + lhs.z*lhs.z
    return math.sqrt(len)
  end,

  __eq = function( lhs,rhs)
    if math.abs( lhs.x - rhs.x) > 0.001 then return false end
    if math.abs( lhs.y - rhs.y) > 0.001 then return false end
    if math.abs( lhs.z - rhs.z) > 0.001 then return false end
    return true
  end,

  __tostring = function( self )
    local s = string.format("EC.Vector3: %.6f,%.6f,%.6f",self.x,self.y,self.z) 
    return s
  end,

  Dot = function( self, rhs )
    return self.x * rhs.x + self.y * rhs.y + self.z * rhs.z
  end,

  Set = function(self,_x,_y,_z)
  	--paramcheck(_x)
  	--paramcheck(_y)
  	--paramcheck(_z)
    -- Modified by zzy At 2022.4.22: 只读标记
    if self._readOnly then
      error("这个Vector3是只读的，不能使用Set去修改它的值，请检查逻辑！", 2);
      return;
    end

    self.x = _x; self.y = _y; self.z = _z;
  end,
  
  Assign = function(self, _src)
    -- self.x = _src.x
    -- self.y = _src.y
    -- self.z = _src.z
    self:Set(_src.x, _src.y, _src.z);
  end,

  Cross = function( self, rhs)
    return EC.Vector3.new(  self.y*rhs.z - self.z*rhs.y, 
			    self.z*rhs.x - self.x*rhs.z,
			    self.x*rhs.y - self.y*rhs.x);
  end,

  Normalize = function( self )
    local f
    if self.Length == 0 then
      f = 0
    else
      f = 1/self.Length
    end
    self.x = self.x * f; self.y = self.y * f; self.z = self.z * f
  end,

  get_Length = function ( self )
    local len = math.sqrt(self.x*self.x + self.y*self.y + self.z*self.z)
    return len
  end,

  Scale = function(self, rhs)
    local ret = EC.Vector3.new(self.x*rhs.x, self.y*rhs.y, self.z*rhs.z)
    return ret
  end
}


EC.Vector3.__index = function(t,k)
  local mt = getmetatable(t)
  local v = mt[k]
  if v then return v end
  v = mt["get_" .. k]
  if v then return v(t) end
  return nil
end

_G._Vector3Ctor_ = EC.Vector3.new

-- EC.Vector3.back = EC.Vector3.new(0,0,-1)
-- EC.Vector3.down= EC.Vector3.new(0,-1,0)
-- EC.Vector3.forward = EC.Vector3.new(0,0,1)
-- EC.Vector3.left= EC.Vector3.new(-1,0,0)
-- EC.Vector3.one= EC.Vector3.new(1,1,1)
-- EC.Vector3.right = EC.Vector3.new(1,0,0)
-- EC.Vector3.up= EC.Vector3.new(0,1,0)
-- EC.Vector3.zero= EC.Vector3.new(0,0,0)

-- Modified by zzy At 2022.4.22: 使得这些表变为只读，以免被调用端修改
local function InnerReadOnly(t)
  t._readOnly = true;
  return t;
end

---将传入的表变为只读，并返回一张新表作为访问的表
---@param preTbl table
---@return table
function _G.GetReadOnlyTable(preTbl)
    local proxy = {};
    local mt = {};
    setmetatable(proxy, mt);
    -- 拷贝元方法
    _G.CopyMetaMethod(proxy, preTbl);
    -- 重写 get and set
    mt.__index = preTbl;
    mt.__newindex = function (t, k, v)
        error("尝试修改一个只读的表，请检查逻辑！", 2);
    end
    return proxy;
end


---将b的原方法全部拷贝到a的原方法中
---@param a table
---@param b table
function _G.CopyMetaMethod(a, b)
    if not a or not b or type(a) ~= "table" or type(b) ~= "table" then
        return;
    end

    local ma = getmetatable(a);
    local mb = getmetatable(b);

    ma.__add = mb.__add;
    ma.__sub = mb.__sub;
    ma.__mul = mb.__mul;
    ma.__div = mb.__div;
    ma.__mod = mb.__mod;
    ma.__pow = mb.__pow;
    ma.__unm = mb.__unm;
    ma.__concat = mb.__concat;
    ma.__len = mb.__len;
    ma.__lt = mb.__lt;
    ma.__le = mb.__le;
    ma.__index = mb.__index;
    ma.__newindex = mb.__newindex;
    ma.__call = mb.__call;
    ma.__pairs = mb.__pairs;
    ma.__ipairs = mb.__ipairs;
    if _VERSION == 'Lua 5.3' or _VERSION == 'Lua 5.4' then
        ma.__idiv = mb.__idiv;
        ma.__band = mb.__band;
        ma.__bor = mb.__bor;
        ma.__bxor = mb.__bxor;
        ma.__bnot = mb.__bnot;
        ma.__shl = mb.__shl;
        ma.__shr = mb.__shr;
    end
end

EC.Vector3.back = _G.GetReadOnlyTable(InnerReadOnly(EC.Vector3.new(0,0,-1)))
EC.Vector3.down= _G.GetReadOnlyTable(InnerReadOnly(EC.Vector3.new(0,-1,0)))
EC.Vector3.forward = _G.GetReadOnlyTable(InnerReadOnly(EC.Vector3.new(0,0,1)))
EC.Vector3.left= _G.GetReadOnlyTable(InnerReadOnly(EC.Vector3.new(-1,0,0)))
EC.Vector3.one= _G.GetReadOnlyTable(InnerReadOnly(EC.Vector3.new(1,1,1)))
EC.Vector3.right = _G.GetReadOnlyTable(InnerReadOnly(EC.Vector3.new(1,0,0)))
EC.Vector3.up= _G.GetReadOnlyTable(InnerReadOnly(EC.Vector3.new(0,1,0)))
EC.Vector3.zero= _G.GetReadOnlyTable(InnerReadOnly(EC.Vector3.new(0,0,0)))

--print("----------  Vector3 in Lua")

return EC
----------------------------------------------------------------------------------------
