-- ============================================================================
-- BeyondMain / Premake 5
-- Location: repo/build/build/premake5.lua
--
-- src/ is entirely user-managed: there are NO hardcoded chapter or category
-- directories. Every supported file in src/ (including nested directories)
-- is discovered at generation time.
-- ============================================================================

local toolsDir    = path.getabsolute(_MAIN_SCRIPT_DIR)
local repoRoot    = path.getabsolute(path.join(toolsDir, "../.."))
local buildRoot   = path.join(repoRoot, "build")
local projectsDir = path.join(repoRoot, "proj")
local srcDir      = path.join(repoRoot, "src")

workspace "BeyondMain"
    location(projectsDir)
    configurations { "Debug", "Release" }
    platforms { "x64" }
    architecture "x86_64"
    startproject "BeyondMain"

project "BeyondMain"
    location(projectsDir)
    kind "ConsoleApp"
    language "C++"
    cppdialect "C++20"
    staticruntime "Off"
    targetname "BeyondMain"

    targetdir(path.join(buildRoot, "bin", "%{cfg.buildcfg}-%{cfg.platform}"))
    objdir(path.join(buildRoot, "obj", "%{cfg.buildcfg}-%{cfg.platform}", "%{prj.name}"))
    debugdir(repoRoot)

    includedirs {
        path.join(_MAIN_SCRIPT_DIR, "../../src/Core")
    }

    -- Recursively include files from ANY user-created folder under src/.
    files {
        path.join(srcDir, "**.cpp"),
        path.join(srcDir, "**.cc"),
        path.join(srcDir, "**.cxx"),
        path.join(srcDir, "**.h"),
        path.join(srcDir, "**.hpp"),
        path.join(srcDir, "**.hxx"),
        path.join(srcDir, "**.inl"),
        path.join(srcDir, "**.tpp"),
        path.join(srcDir, "**.md"),  -- Existing Markdown is included, never created.
    }

    -- Show the current on-disk src/ hierarchy in Solution Explorer.
    vpaths { ["*"] = srcDir }
    includedirs { srcDir }
    warnings "Extra"

    filter "system:windows"
        systemversion "latest"
        defines { "NOMINMAX", "WIN32_LEAN_AND_MEAN" }

    filter "action:vs*"
        buildoptions { "/MP", "/utf-8" }

    filter "configurations:Debug"
        defines { "_DEBUG" }
        runtime "Debug"
        symbols "On"
        optimize "Off"

    filter "configurations:Release"
        defines { "NDEBUG" }
        runtime "Release"
        symbols "On"
        optimize "Speed"

    filter {}
