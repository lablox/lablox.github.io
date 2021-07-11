--[[
This filter is written by Mr. Albert Krewinkel:
https://groups.google.com/d/msg/pandoc-discuss/k_Vq-M-ArbQ/go0H9k9jBQAJ
]]

string.uc_lower = (require 'text').lower

function Header (h)
  -- do nothing if the identifier is already set
  if h.identifier ~= '' then return nil end

  h.identifier = pandoc.utils.stringify(h)
    :lower()
    :gsub('[^%w%s%-]', '')
    :gsub('%s', '_')
  return h
end
