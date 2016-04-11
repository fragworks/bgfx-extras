--
-- Copyright 2010-2016 Branimir Karadzic. All rights reserved.
-- License: https://github.com/bkaradzic/bgfx#license-bsd-2-clause
--

newoption {
	trigger = "with-shared-lib",
	description = "Enable building shared library.",
}

solution "bgfx-extras"
	configurations {
		"Debug",
		"Release",
	}

	if _ACTION == "xcode4" then
		platforms {
			"Universal",
		}
	else
		platforms {
			"x32",
			"x64",
--			"Xbox360",
			"Native", -- for targets where bitness is not specified
		}
	end

	language "C++"

BGFX_EXTRAS_DIR = path.getabsolute("..")
BGFX_DIR = os.getenv("BGFX_DIR")
BX_DIR   = os.getenv("BX_DIR")

local BGFX_EXTRAS_BUILD_DIR = path.join(BGFX_EXTRAS_DIR, ".build")
local BGFX_THIRD_PARTY_DIR = path.join(BGFX_DIR, "3rdparty")
if not BX_DIR then
	BX_DIR = path.getabsolute(path.join(BGFX_EXTRAS_DIR, "../bx"))
end
if not BGFX_DIR then
	BGFX_DIR = path.getabsolute(path.join(BGFX_EXTRAS_DIR, "../bgfx"))
end

if not os.isdir(BX_DIR) then
	print("bx not found at " .. BX_DIR)
	print("For more info see: https://bkaradzic.github.io/bgfx/build.html")
	os.exit()
end

if not os.isdir(BGFX_DIR) then
	print("bgfx not found at " .. BGFX_DIR)
	print("For more info see: https://bkaradzic.github.io/bgfx/build.html")
	os.exit()
end

defines {
	"BX_CONFIG_ENABLE_MSVC_LEVEL4_WARNINGS=1"
}

dofile (path.join(BX_DIR, "scripts/toolchain.lua"))
if not toolchain(BGFX_EXTRAS_BUILD_DIR, BGFX_THIRD_PARTY_DIR) then
	return -- no action specified
end

function copyLib()
end

if _OPTIONS["with-sdl"] then
	if os.is("windows") then
		if not os.getenv("SDL2_DIR") then
			print("Set SDL2_DIR enviroment variable.")
		end
	end
end

if _OPTIONS["with-profiler"] then
	defines {
		"ENTRY_CONFIG_PROFILER=1",
		"BGFX_CONFIG_PROFILER_REMOTERY=1",
        "_WINSOCKAPI_"
	}
end

dofile "bgfx-extras.lua"

group "libs"
bgfxExtrasProject("", "StaticLib", {})

if _OPTIONS["with-shared-lib"] then
	group "libs"
	bgfxExtrasProject("-shared-lib", "SharedLib", {})
end
