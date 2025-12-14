-- Function defined in manifest.ini
-- wiki: function to be called each frame to draw window content
---
function script.MANIFEST__FUNCTION_MAIN(dt)
	ui.text("hi")
end

---
-- wiki: called after a whole simulation update
---
function script.MANIFEST__UPDATE(dt)
  local sim = ac_getSim()
  if sim.isPaused then return end
end

---
-- wiki: called when transparent objects are finished rendering
---
function script.MANIFEST__TRANSPARENT(dt)
end
