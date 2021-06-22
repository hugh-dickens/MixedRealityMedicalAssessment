import myo

class Listener(myo.DeviceListener):
  def on_paired(self, event):
    print("Hello, {}!".format(event.device_name))
    event.device.vibrate(myo.VibrationType.short)
  def on_unpaired(self, event):
    return False  # Stop the hub
  def on_orientation(self, event):
    orientation = event.orientation
    acceleration = event.acceleration
    gyroscope = event.gyroscope
    # ... do something with that

if __name__ == '__main__':
  myo.init(sdk_path='./myo-sdk-win-0.9.0/')
  hub = myo.Hub()
  listener = Listener()
  while hub.run(listener.on_event, 500):
    pass
