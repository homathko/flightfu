# FlightFu
### Description
FlightFu is an experimental API that should enable 
an iOS device to determine the state of flight of a 
small single piston engine aircraft. It is an event-driven
state machine that manages nested sub states.

### System States
#### Idle
Awaiting a change to the Armed state.
#### Armed
Sensing for velocity and audio input signals to send a 
system event that signifies the flight has commenced. According
to the CARs an aircraft's flight time will commence once
the aircraft's engine is on, and brakes have been released
for the first time. These are both "flight events", as opposed
to "system events". Combinations of these flight events cause 
changes to the System State, and those combinations that cause
flight events are different per System State.

```
isCapturingFlight = engineState == EngineStateRunning && velocityState == VelocityStateRolling
```
```
isDoneCapturingFlight = engineState == EngineStateSecure && velocityState == VelocityStateStationary
```

#### TODO: Capturing
Once in this state, FlightFu will track events to create
key flight metrics. For example the key metric "flight time" 
equals the interval of time between entering AppStateCapturing 
and AppStateIdle, and the key metric "air time" equals
the sum of a series of corresponding "wheels up" and "wheels down"
event pairs.

#### To be continued...