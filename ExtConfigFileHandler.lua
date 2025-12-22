--- A standalone module to handle reading and writing to ext_config.ini files for tracks and track layouts in Assetto Corsa.
local ExtConfigFileHandler = {}

---@enum ExtConfigFileHandler.ExtConfigFileTypes 
ExtConfigFileHandler.ExtConfigFileTypes ={
    -- E:\Games\Steam\steamapps\common\assettocorsa\content\tracks\ks_nordschleife\extension\ext_config.ini
    Track = 1,
    -- E:\Games\Steam\steamapps\common\assettocorsa\content\tracks\ks_nordschleife\touristenfahrten\extension\ext_config.ini
    TrackLayout = 2,
}

-- ExtConfigFileHandler.EXTENSION_PATH = '/extension/'
ExtConfigFileHandler.EXTENSION_PATH = '\\extension\\'
ExtConfigFileHandler.EXT_CONFIG_FILENAME = 'ext_config.ini'
ExtConfigFileHandler.EXT_CONFIG_RELATIVE_PATH = ExtConfigFileHandler.EXTENSION_PATH .. ExtConfigFileHandler.EXT_CONFIG_FILENAME

local trackFolder = ac.getFolder(ac.FolderID.CurrentTrack)
local trackLayoutFolder = ac.getFolder(ac.FolderID.CurrentTrackLayout)

---@type table<ExtConfigFileHandler.ExtConfigFileTypes, string> 
local availableDirectories = {
    [ExtConfigFileHandler.ExtConfigFileTypes.Track] = trackFolder,
    [ExtConfigFileHandler.ExtConfigFileTypes.TrackLayout] = trackLayoutFolder,
}

---@type table<ExtConfigFileHandler.ExtConfigFileTypes, string> 
local availableFiles = {
    [ExtConfigFileHandler.ExtConfigFileTypes.Track] = string.format('%s%s', trackFolder, ExtConfigFileHandler.EXT_CONFIG_RELATIVE_PATH),
    [ExtConfigFileHandler.ExtConfigFileTypes.TrackLayout] = string.format('%s%s', trackLayoutFolder, ExtConfigFileHandler.EXT_CONFIG_RELATIVE_PATH),
}

--[==[
ac.log('Track Folder: ' .. availableDirectories[ExtConfigFileHandler.ExtConfigFileTypes.Track])
ac.log('Track ext_config.ini file: ' .. availableFiles[ExtConfigFileHandler.ExtConfigFileTypes.Track])
ac.log()
ac.log('Track Layout Folder: ' .. availableDirectories[ExtConfigFileHandler.ExtConfigFileTypes.TrackLayout])
ac.log('Track Layout ext_config.ini file: ' .. availableFiles[ExtConfigFileHandler.ExtConfigFileTypes.TrackLayout])
--]==]

---@param extConfigFileType ExtConfigFileHandler.ExtConfigFileTypes @The type of ext_config.ini file to write to
---@param sectionName string @The section name prefix, e.g., "FLAME"
---@param setCallback fun(file: ac.INIConfig, fullSectionName: string) @A callback function that receives the INIConfig object and the full section name to set values in the new section
ExtConfigFileHandler.writeNewSectionToExtConfigFile = function (extConfigFileType, sectionName, setCallback)
    local extConfigFilePath = availableFiles[extConfigFileType]
    ac.log('Writing to ext_config.ini file at: ' .. extConfigFilePath)

    local sectionNameLength = string.len(sectionName)

    -- open the file for reading and writing
    local file = ac.INIConfig.load(extConfigFilePath, ac.INIFormat.Extended, nil)

    -- find the largest existing section name index for the given section prefix
    local largestSectionNameIndex = 0
    for index, section in file:iterate(sectionName) do -- example => index: 1, section: "FLAME_0"
        -- ac.log('FLAME section index: ' .. tostring(index))
        ac.log(string.format('%s section index %d: %s', sectionName, index, section))

        -- extract the numeric part from the section name by taking the substring after 'FLAME_' without using regexes
        -- local sectionNameSuffix = string.sub(section, 7) -- 'FLAME_' has 6 characters, so start from the 7th character
        local sectionNameSuffix = string.sub(section, sectionNameLength + 1 + 1) -- + 1 to move past the last character, + 1 more to start after the underscore
        ac.log(string.format('%s section name suffix: %s', sectionName, sectionNameSuffix))
        local sectionNameIndex = tonumber(sectionNameSuffix)
        if sectionNameIndex and sectionNameIndex > largestSectionNameIndex then
            largestSectionNameIndex = sectionNameIndex
        end
    end

    local nextSectionNameIndex = largestSectionNameIndex + 1
    -- ac.log('Next FLAME section name index: ' .. tostring(nextSectionNameIndex))
    -- local nextSectionName = string.format('FLAME_%d', nextSectionNameIndex)
    local fullNextSectionName = string.format('%s_%d', sectionName, nextSectionNameIndex)
    -- ac.log('Next FLAME section name: ' .. tostring(nextSectionName))
    ac.log(string.format('Next %s section name: %s', sectionName, fullNextSectionName))

    setCallback(file, fullNextSectionName)

    -- save the modified file
    file:save(extConfigFilePath)
    ac.log(string.format('Saved ext_config.ini with new %s section at: %s', sectionName, extConfigFilePath))

end

return ExtConfigFileHandler