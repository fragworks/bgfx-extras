--
-- Copyright 2010-2016 Branimir Karadzic. All rights reserved.
-- License: https://github.com/bkaradzic/bgfx#license-bsd-2-clause
--
--
-- Copyright 2010-2016 Branimir Karadzic. All rights reserved.
-- License: https://github.com/bkaradzic/bgfx#license-bsd-2-clause
--

function bgfxExtrasProject(_name, _kind, _defines)

	project ("bgfx-extras" .. _name)
		uuid (os.uuid("bgfx-extras" .. _name))
		kind (_kind)

		if _kind == "SharedLib" then
			defines {
				"BGFX_SHARED_LIB_BUILD=1",
			}

			configuration { "vs20* or mingw*" }
				links {
					"gdi32",
					"psapi",
				}

			configuration { "mingw*" }
				linkoptions {
					"-shared",
				}

			configuration { "linux-*" }
				buildoptions {
					"-fPIC",
				}

			configuration {}
		end

		includedirs {
			path.join(BX_DIR,   "include"),
		    path.join(BGFX_DIR, "include"),
			path.join(BGFX_DIR, "3rdparty"),
			path.join(BGFX_EXTRAS_DIR, "src/imgui"),
			path.join(BGFX_EXTRAS_DIR, "src/nanovg"),
		}

		defines {
			_defines,
		}

		configuration { "Debug" }
			defines {
				"BGFX_CONFIG_DEBUG=1",
			}

		configuration { "android*" }
			links {
				"EGL",
				"GLESv2",
			}

		configuration { "winphone8* or winstore8*" }
			linkoptions {
				"/ignore:4264" -- LNK4264: archiving object file compiled with /ZW into a static library; note that when authoring Windows Runtime types it is not recommended to link with a static library that contains Windows Runtime metadata
			}

		configuration { "*clang*" }
			buildoptions {
				"-Wno-microsoft-enum-value", -- enumerator value is not representable in the underlying type 'int'
				"-Wno-microsoft-const-init", -- default initialization of an object of const type '' without a user-provided default constructor is a Microsoft extension
			}

		configuration { "osx" }
			linkoptions {
				"-framework Cocoa",
				"-framework QuartzCore",
				"-framework OpenGL",
				"-weak_framework Metal",
			}

		configuration { "not nacl", "not linux-steamlink" }
			includedirs {
				--nacl has GLES2 headers modified...
				--steamlink has EGL headers modified...
				path.join(BGFX_DIR, "3rdparty/khronos"),
			}

		configuration { "linux-steamlink" }
			defines {
				"EGL_API_FB",
			}

		configuration {}

		files {
		    path.join(BGFX_DIR, "3rdparty/ocornut-imgui/**.cpp"),
		    path.join(BGFX_DIR, "3rdparty/ocornut-imgui/**.h"),
		    
			path.join(BGFX_EXTRAS_DIR, "src/**.h"),
			path.join(BGFX_EXTRAS_DIR, "src/**.cpp"),
		}

		removefiles {
			path.join(BGFX_EXTRAS_DIR, "src/**.bin.h"),
		}
		
		if _OPTIONS["with-sdl"] then
		    defines {
			    "ENTRY_CONFIG_USE_SDL=1",
		    }
		    includedirs {
			    "$(SDL2_DIR)/include",
		    }
	    end
	    
	    if _OPTIONS["with-glfw"] then
		    defines {
			    "ENTRY_CONFIG_USE_GLFW=1",
		    }
	    end

		configuration { "linux-steamlink" }
		    defines {
			    "EGL_API_FB",
		    }

		copyLib()
end
