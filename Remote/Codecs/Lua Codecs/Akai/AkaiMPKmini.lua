-- Akai MPK mini Lua Codec
-- David Antliff, Pitchblende Ltd., February 2013
-- Carlos Eduardo, March 2015
-- Version 0.0.5
--  - Added soft takeover mode based on novation implementation
-- Version 0.0.4
--  - Changed CC functions
-- Version 0.0.3
--  - add Sustain support, shift pad CCs up from 64 to 65
-- Version 0.0.2
--  - add support for Transport controls in Record 1.5
-- Version 0.0.1
--  - initial version

-- this is the array index in 'items' for the first pad button. The array is 1-based.
g_first_padbutton_index = 11

-- this is the number of pad buttons - 2 banks x 8 buttons
g_num_padbuttons = 16

-- this is the CC # for the first pad button. This codec assumes the nth button generates this + n - 1.
g_first_padbutton_cc = 65

--position of first analog control in the items table
gFirstAnalogIndex = 3

function remote_init()
	local items={
		{name="Keyboard", input="keyboard"},
		{name="Sustain", input="value", min=0, max=127},
		{name="Knob 1", input="value", min=0, max=127},
		{name="Knob 2", input="value", min=0, max=127},
		{name="Knob 3", input="value", min=0, max=127},
		{name="Knob 4", input="value", min=0, max=127},
		{name="Knob 5", input="value", min=0, max=127},
		{name="Knob 6", input="value", min=0, max=127},
		{name="Knob 7", input="value", min=0, max=127},
		{name="Knob 8", input="value", min=0, max=127},
		-- this item must be at position g_first_padbutton_index (1-based)
		{name="Pad Button 1", input="button"},
		{name="Pad Button 2", input="button"},
		{name="Pad Button 3", input="button"},
		{name="Pad Button 4", input="button"},
		{name="Pad Button 5", input="button"},
		{name="Pad Button 6", input="button"},
		{name="Pad Button 7", input="button"},
		{name="Pad Button 8", input="button"},
		{name="Pad Button 9", input="button"},
		{name="Pad Button 10", input="button"},
		{name="Pad Button 11", input="button"},
		{name="Pad Button 12", input="button"},
		{name="Pad Button 13", input="button"},
		{name="Pad Button 14", input="button"},
		{name="Pad Button 15", input="button"},
		{name="Pad Button 16", input="button"},

		{name="Prog Change 1", input="button"},
		{name="Prog Change 2", input="button"},
		{name="Prog Change 3", input="button"},
		{name="Prog Change 4", input="button"},
		{name="Prog Change 5", input="button"},
		{name="Prog Change 6", input="button"},
		{name="Prog Change 7", input="button"},
		{name="Prog Change 8", input="button"},
		{name="Prog Change 9", input="button"},
		{name="Prog Change 10", input="button"},
		{name="Prog Change 11", input="button"},
		{name="Prog Change 12", input="button"},
		{name="Prog Change 13", input="button"},
		{name="Prog Change 14", input="button"},
		{name="Prog Change 15", input="button"},
		{name="Prog Change 16", input="button"},
	}
	remote.define_items(items)

	local inputs={
		{pattern="b? 40 xx", name="Sustain"},
		{pattern="b? 01 xx", name="Knob 1"},
		{pattern="b? 02 xx", name="Knob 2"},
		{pattern="b? 03 xx", name="Knob 3"},
		{pattern="b? 04 xx", name="Knob 4"},
		{pattern="b? 05 xx", name="Knob 5"},
		{pattern="b? 06 xx", name="Knob 6"},
		{pattern="b? 07 xx", name="Knob 7"},
		{pattern="b? 08 xx", name="Knob 8"},

		{pattern="80 xx yy", name="Keyboard", value="0", note="x", velocity="64"},

		{pattern="90 xx 00", name="Keyboard", value="0", note="x", velocity="64"},
		{pattern="<100x>0 yy zz", name="Keyboard"},

		-- pad CCs are handled by remote_process_midi() below

		-- pad Program Change
		{pattern="C? 00", name="Prog Change 1", value="1"},
		{pattern="C? 01", name="Prog Change 2", value="1"},
		{pattern="C? 02", name="Prog Change 3", value="1"},
		{pattern="C? 03", name="Prog Change 4", value="1"},
		{pattern="C? 04", name="Prog Change 5", value="1"},
		{pattern="C? 05", name="Prog Change 6", value="1"},
		{pattern="C? 06", name="Prog Change 7", value="1"},
		{pattern="C? 07", name="Prog Change 8", value="1"},
		{pattern="C? 08", name="Prog Change 9", value="1"},
		{pattern="C? 09", name="Prog Change 10", value="1"},
		{pattern="C? 0a", name="Prog Change 11", value="1"},
		{pattern="C? 0b", name="Prog Change 12", value="1"},
		{pattern="C? 0c", name="Prog Change 13", value="1"},
		{pattern="C? 0d", name="Prog Change 14", value="1"},
		{pattern="C? 0e", name="Prog Change 15", value="1"},
		{pattern="C? 0f", name="Prog Change 16", value="1"},
	}
	remote.define_auto_inputs(inputs)
end

--"Analogs" indicates non-encoder analog controls and refers to both knobs and sliders on the nanoKONTROL
gNumberOfAnalogs = 8

--converts CC numbers to slider/knob numbers
gAnalogCCLookup = {
	[1]=1,[2]=2,[3]=3,[4]=4,[5]=5,[6]=6,[7]=7,[8]=8 --Knobs 1-8
}

gAnalogPhysicalState, gAnalogMachineState, gAnalogMismatch, gLastAnalogMoveTime, gSentValueSettleTime = {}, {}, {}, {}, {}

for i = 1, gNumberOfAnalogs do --set up slider/knob tracking arrays
	gAnalogPhysicalState[i] = 0 --stores current position/value of control on hardware
	gAnalogMachineState[i] = 0 --stores value of connected software item
	gAnalogMismatch[i] = nil --difference between physical state of control and software value (positive numbers indicate physical value is greater, nil indicates mismatch assumption due to unknown physical state at startup)
	gLastAnalogMoveTime[i] = 0 --stores timestamp of last time knob/slider was moved on hardware
	gSentValueSettleTime[i] = 250 --number of milliseconds to wait for a sent slider or knob value to be echoed back before reevaluating synchronization
end

--acceptable difference between the first reported value from a control and the machine state for the 2 to be considered synchronized
gStartupLiveband = 3

function remote_process_midi(event) --manual handling of incoming values sent by controller
	--Analog Messages
	ret=remote.match_midi("B? yy xx", event) --check for slider/knob messages
	if ret~=nil then
		-- only catch button events
		if ret.y >= g_first_padbutton_cc and ret.y <= (g_first_padbutton_cc + g_num_padbuttons) then
			local val = (ret.x ~= 0) and 1 or 0
			-- Make a remote message. item is the index in the control surface item list. 0-1, release-press.
			local msg = {
				time_stamp = event.time_stamp,
				item = g_first_padbutton_index + ret.y - g_first_padbutton_cc,
				value = val
			}
			remote.handle_input(msg)
			return true
		end
		local AnalogNum = gAnalogCCLookup[ret.y] --try to get the analog number that corresponds to the received Continuous Controller message
		if AnalogNum == nil then --if message isn't from an analog
			return false --pass it on to auto input handling
		else
			gAnalogPhysicalState[AnalogNum] = ret.x --update the stored physical state to the incoming value
			local AllowChange = true --we'll send the incoming value to the host unless we find a reason not to

			if gAnalogMismatch[AnalogNum] ~= 0 then --assess conditions if controller and software values are mismatched
				if gAnalogMismatch[AnalogNum] == nil then --startup condition: analog hasn't reported in yet
					gAnalogMismatch[AnalogNum] = gAnalogPhysicalState[AnalogNum] - gAnalogMachineState[AnalogNum] --calculate and store how physical and machine states relate to each other
					if math.abs(gAnalogMismatch[AnalogNum]) > gStartupLiveband then --if the physical value is too far from the machine value
						AllowChange = false --don't send it to Reason
					end
				elseif gAnalogMismatch[AnalogNum] > 0 and gAnalogPhysicalState[AnalogNum] - gAnalogMachineState[AnalogNum] > 0 then --if physical state of analog was and still is above virtual value
					AllowChange = false --don't send the new value to Reason because it's out of sync
				elseif gAnalogMismatch[AnalogNum] < 0 and gAnalogPhysicalState[AnalogNum] - gAnalogMachineState[AnalogNum] < 0 then --if physical state of analog was and still is below virtual value
					AllowChange = false --don't send the updated value
				end
			end

			if AllowChange then --if the incoming change should be sent to Reason
				remote.handle_input({ time_stamp=event.time_stamp, item=gFirstAnalogIndex + AnalogNum - 1, value=ret.x }) --send the new analog value to Reason
				gLastAnalogMoveTime[AnalogNum] = remote.get_time_ms() --store the time this change was sent
				gAnalogMismatch[AnalogNum] = 0 --and set the flag to show the controller and Reason are in sync
			end
			return true --input has been handled
		end
	end
	return false
end

function remote_set_state(changed_items) --handle incoming changes sent by Reason
	for i,item_index in ipairs(changed_items) do
		local AnalogNum = item_index - gFirstAnalogIndex + 1 --calculate which analog (if any) the index of the changed item indicates
		if AnalogNum >= 1 and AnalogNum <= gNumberOfAnalogs then --if change belongs to an analog control
			gAnalogMachineState[AnalogNum] = remote.get_item_value(item_index) --update the machine state for the analog
			if gAnalogMismatch[AnalogNum] ~= nil then --if we know the analog's physical state
				if (remote.get_time_ms() - gLastAnalogMoveTime[AnalogNum]) > gSentValueSettleTime[AnalogNum] then --and the last value it sent to Reason happened outside the settle time
					gAnalogMismatch[AnalogNum] = gAnalogPhysicalState[AnalogNum] - gAnalogMachineState[AnalogNum] --recalculate and store how physical and machine states relate to each other
				end
			end
		end
	end
end

function remote_probe()
  local controlRequest="F0 7E 7F 06 01 F7"
  local controlResponse="F0 7E 00 06 02 47 7C 00 19 00 ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? F7"
  return {
    request=controlRequest,
    response=controlResponse
  }
end

--[[
function trace_event(event)
  result = "Event: "
  result = result .. "port " .. event.port .. ", "
  result = result .. (event.timestamp and ("timestamp " .. event.timestamp .. ", ") or "")
  result = result .. (event.hi and ("hi " .. event.hi .. ", ") or "")
  result = result .. (event.lo and ("lo " .. event.lo .. ", ") or "")
  result = result .. (event.size and ("size " .. event.size .. ", ") or "")

  result = result .. "data {"
  for i=1,event.size do
     result = result .. event[i] .. ", "
  end
  result = result .. "}, "

  remote.trace(result)
end
]]--
