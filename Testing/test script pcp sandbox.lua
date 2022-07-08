function save_message(message)
savepath = "Saved to "
message = savepath .. "Hello World"
reaper.ShowMessageBox(message, "Reaclip saved", 0)
os.exit()
end

filename = os.date
