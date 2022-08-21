from obspy import UTCDateTime
starttime =UTCDateTime('2018-04-30T14:00:00-10')
endtime=starttime + 24 * 60 * 60
from obspy.clients.fdsn import Client
client = Client("IRIS")
inv = client.get_stations(network="HV", station="*", channel="EHZ", level="channel", starttime=starttime, endtime=endtime, minlatitude="19.25", maxlatitude="19.75", minlongitude="-155.22", maxlongitude="-154")
import matplotlib
matplotlib.use('TKAgg')
#inv.plot(projection="local")
#print(inv.get_contents()['channels'])
#print(inv.get_coordinates("HV.KLUD..EHZ", starttime)) 
stream = client.get_waveforms("HV", "KLUD", "", "EHZ", starttime, endtime)
#stream.plot(type="dayplot", interval=60) 
lat1 = 19.386389
lon1 = -155.105
lat2 = 19.455728
lon2 = -154.918443
from obspy.clients.iris import Client
iris = Client()
result = iris.distaz(lat1, lon1, lat2, lon2)
print(result) 
