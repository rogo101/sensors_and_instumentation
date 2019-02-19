# -*- coding: utf-8 -*-

#%%
# import various libraries necessery to run your Python code
import visa
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import time   # time related library
import sys    # system related library
ok_loc = 'C:\\Program Files\\Opal Kelly\\FrontPanelUSB\\API\\Python\\3.6\\x64'
sys.path.append(ok_loc)   # add the path of the OK library
import ok     # OpalKelly library
import statistics 
from scipy.ndimage.filters import gaussian_filter1d
mpl.style.use('ggplot')

#%% 
# Define FrontPanel device variable, open USB communication and
# load the bit file in the FPGA
dev = ok.okCFrontPanel()  # define a device for FrontPanel communication
SerialStatus=dev.OpenBySerial("")      # open USB communicaiton with the OK board
ConfigStatus=dev.ConfigureFPGA("C:\\Users\\nlao2\\lab_5\\lab_5.runs\\impl_1\\JTEG_TEST_FILE.bit"); # Configure the FPGA with this bit file

# Check if FrontPanel is initialized correctly and if the bit file is loaded.
# Otherwise terminate the program
print("----------------------------------------------------")
if SerialStatus == 0:
    print ("FrontPanel host interface was successfully initialized.")
else:    
    print ("FrontPanel host interface not detected. The error code number is:" + str(int(SerialStatus)))
    print("Exiting the program.")
    sys.exit ()

if ConfigStatus == 0:
    print ("Your bit file is successfully loaded in the FPGA.")
else:
    print ("Your bit file did not load. The error code number is:" + str(int(ConfigStatus)))
    print ("Exiting the progam.")
    sys.exit ()
print("----------------------------------------------------")
print("----------------------------------------------------")

#%%
#%%
# This section of the code cycles through all USB connected devices to the computer.
# The code figures out the USB port number for each instrument.
# The port number for each instrument is stored in a variable named “instrument_id”
# If the instrument is turned off or if you are trying to connect to the 
# keyboard or mouse, you will get a message that you cannot connect on that port.
device_manager = visa.ResourceManager()
devices = device_manager.list_resources()
number_of_device = len(devices)

power_supply_id = -1;
waveform_generator_id = -1;
digital_multimeter_id = -1;
oscilloscope_id = -1;

# assumes only the DC power supply is connected
for i in range (0, number_of_device):

# check that it is actually the power supply
    try:
        device_temp = device_manager.open_resource(devices[i])
        print("Instrument connect on USB port number [" + str(i) + "] is " + device_temp.query("*IDN?"))
        if (device_temp.query("*IDN?") == 'HEWLETT-PACKARD,E3631A,0,3.0-6.0-2.0\r\n'):
            power_supply_id = i        
        if (device_temp.query("*IDN?") == 'Agilent Technologies,33511B,MY52301259,3.03-1.19-2.00-52-00\n'):
            waveform_generator_id = i
        if (device_temp.query("*IDN?") == 'Agilent Technologies,34461A,MY53208021,A.01.10-02.25-01.10-00.35-01-01\n'):
            digital_multimeter_id = i            
        if (device_temp.query("*IDN?") == 'KEYSIGHT TECHNOLOGIES,MSO-X 3024T,MY54440307,07.10.2017042905\n'):
            oscilloscope_id = i                        
        device_temp.close()
    except:
        print("Instrument on USB port number [" + str(i) + "] cannot be connected. The instrument might be powered off or you are trying to connect to a mouse or keyboard.\n")
    

#%%
# Open the USB communication port with the power supply.
# The power supply is connected on USB port number power_supply_id.
# If the power supply ss not connected or turned off, the program will exit.
# Otherwise, the power_supply variable is the handler to the power supply
    
if (power_supply_id == -1):
    print("Power supply instrument is not powered on or connected to the PC.")    
else:
    print("Power supply is connected to the PC.")
    power_supply = device_manager.open_resource(devices[power_supply_id])
    
if (oscilloscope_id == -1):
    print("Oscilloscope instrument is not powered on or connected to the PC.")    
else:
    print("Oscilloscope is connected to the PC.")
    osci = device_manager.open_resource(devices[oscilloscope_id])
    
if (digital_multimeter_id == -1):
    print("Multimeter instrument is not powered on or connected to the PC.")    
else:
    print("Multimeter is connected to the PC.")
    multi = device_manager.open_resource(devices[digital_multimeter_id])    
    
#%%
print('\n')
# The power supply output voltage will be swept from 0 to 1.5V in steps of 0.05V.
# This voltage will be applied on the 6V output ports.
# For each voltage applied on the 6V power supply, we will measure the actual 
# voltage and current supplied by the power supply.
# If your circuit operates correctly, the applied and measured voltage will be the same.
# If the power supply reaches its maximum allowed current, 
# then the applied voltage will not be the same as the measured voltage.

output_voltage = np.arange(0, 4.8096, 0.096)

voltage_mean = []
voltage_std = []
current_mean = []
current_std = []
power_consumption_mean = []
power_consumption_std = []
temperature_mean = []
temperature_std = []

print(power_supply.write("OUTPUT ON")) # power supply output is turned on
    
    # loop through the different voltages we will apply to the power supply
    # For each voltage applied on the power supply, 
    # measure the voltage and current supplied by the 6V power supply
count = 0    
for v in output_voltage:
    a = 0
    measured_voltage = [] # create an empty list to hold our values
    measured_current = [] # create an empty list to hold our values
    measured_temperature = []
    
    while (a < 100):     
        # apply the desired voltage on teh 6V power supply and limist the output current to 0.5A
        power_supply.write("APPLy P6V, %0.2f" % v)
        # pause 50ms to let things settle
        time.sleep(0.05)
            
        dev.UpdateWireOuts()
        temperature = dev.GetWireOutValue(0x20)
        temperature /= 128
        measured_temperature.append(float(temperature))
            
        # read the output voltage on the 6V power supply
        measured_voltage_tmp = power_supply.query("MEASure:VOLTage:DC? P6V")    
        measured_voltage.append(float(measured_voltage_tmp))
        
        # read the output current on the 6V power supply
        measured_current_tmp = multi.query("MEASure:CURRent:DC?")
        measured_current.append(float(measured_current_tmp))
       
        print(temperature)
        print(measured_voltage_tmp)
        print(measured_current_tmp)
        
        a+=1
        
    voltage_mean.append(abs(statistics.mean(measured_voltage)))
    voltage_mean[count] = round(float(voltage_mean[count]), 2)

    voltage_std.append(statistics.stdev(measured_voltage))
    voltage_std[count] = float(voltage_std[count]) * 10 ** 6
    
    current_mean.append(abs(statistics.mean(measured_current)))
    current_mean[count] = float(current_mean[count]) * 10 ** 3 # mA
    
    current_std.append(statistics.stdev(measured_current))
    current_std[count] = float(current_std[count]) * 10 ** 6
    
    power_consumption_mean.append(voltage_mean[count] ** 2 / 47)
    power_consumption_mean[count] = float(power_consumption_mean[count]) * 10 ** 3
    
    power_consumption_std.append(statistics.stdev(measured_voltage))
    power_consumption_std[count] = float(power_consumption_std[count]) * 10 ** 6
    
    temperature_mean.append(abs(statistics.mean(measured_temperature)))
    temperature_mean[count] = float(temperature_mean[count])
    
    temperature_std.append(statistics.stdev(measured_temperature))
    temperature_std[count] = float(temperature_std[count])
    
    count += 1
     
# power supply output is turned off
print(power_supply.write("OUTPUT OFF"))

# close the power supply USB handler.
# Otherwise you cannot connect to it in the future
power_supply.close()
dev.Close
#%%    
# plot results (applied voltage vs measured supplied current)
#print('\n\n')
#for i in range(0,50):
#    print(voltage_mean[i])
#    print(voltage_std[i])
#    print(current_mean[i])
#    print(current_std[i])
#    print(power_consumption_mean[i])
#    print(power_consumption_std[i])
#    print(temperature_mean[i])
#    print(temperature_std[i])

plt.figure()
plt.plot(output_voltage,voltage_mean,'r--')
plt.scatter(output_voltage,voltage_mean,c='b',s=13)
plt.title("Means' of 100 Voltage Measurements Across Resistor")
plt.xlabel("Applied Voltage [V]")
plt.ylabel("Measured Voltage Mean [V]")
plt.draw()
plt.savefig('lab6_vm.png', dpi=600)

plt.figure()
plt.scatter(output_voltage,voltage_std,c='b',s=13)
plt.title("Std. Deviations' of 100 Voltage Measurements Across Resistor")
plt.xlabel("Applied Voltage [V]")
plt.ylabel("Measured Voltage Std. Dev. [uV]")
plt.draw()
plt.savefig('lab6_vsd.png', dpi=600)

plt.figure()
plt.plot(output_voltage,current_mean,'r--')
plt.scatter(output_voltage,current_mean,c='b',s=13)
plt.title("Means' of 100 Current Measurements Across Resistor")
plt.xlabel("Applied Voltage [V]")
plt.ylabel("Measured Current Mean [mA]")
plt.draw()
plt.savefig('lab6_cm.png', dpi=600)

plt.figure()
plt.scatter(output_voltage,voltage_std,c='b',s=13)
plt.title("Std. Deviations' of 100 Current Measurements Across Resistor")
plt.xlabel("Applied Voltage [V]")
plt.ylabel("Measured Current Std. Dev. [uA]")
plt.draw()
plt.savefig('lab6_csd.png', dpi=600)

plt.figure()
smooth = gaussian_filter1d(power_consumption_mean, sigma=2)
plt.plot(output_voltage,smooth,'r--')
plt.scatter(output_voltage,power_consumption_mean,c='b')
plt.title("Means' of 100 P.C. Measurements Across Resistor")
plt.xlabel("Applied Voltage [V]")
plt.ylabel("Measured Power Consumption Mean [mW]")
plt.draw()
plt.savefig('lab6_pcm.png', dpi=600)

plt.figure()
plt.scatter(output_voltage,power_consumption_std,c='b',s=13)
plt.title("Std. Deviations' of 100 P.C. Measurements Across Resistor")
plt.xlabel("Applied Voltage [V]")
plt.ylabel("Measured P.C. Std. Dev. [uW]")
plt.draw()
plt.savefig('lab6_pcsd.png', dpi=600)

plt.figure()
smooth1 = gaussian_filter1d(temperature_mean, sigma=2)
plt.plot(output_voltage,smooth1,'r--')
plt.scatter(output_voltage,temperature_mean,c='b',s=13)
plt.title("Means' of 100 Temperature Measurements")
plt.xlabel("Applied Voltage [V]")
plt.ylabel("Measured Temperature [Celsius]")
plt.draw()
plt.savefig('lab6_tm.png', dpi=600)

plt.figure()
plt.plot(output_voltage,temperature_std,'r--')
plt.scatter(output_voltage,temperature_std,c='b',s=13)
plt.title("Std. Deviations' of 100 Temperature Measurements")
plt.xlabel("Applied Voltage [V]")
plt.ylabel("Measured Temperature Std. Dev. [Celsius]")
plt.draw()
plt.savefig('lab6_tsd_normal.png', dpi=600)

plt.figure()
plt.scatter(output_voltage,temperature_std,c='b',s=13)
plt.title("Std. Deviations' of 100 Temperature Measurements")
plt.xlabel("Applied Voltage [V]")
plt.ylabel("Measured Temperature Std. Dev. [Celsius]")
plt.draw()
plt.savefig('lab6_tsd_unfitted.png', dpi=600)

plt.figure()
smooth2 = gaussian_filter1d(temperature_std, sigma=2)
plt.plot(output_voltage,smooth2,'r--')
#plt.plot(output_voltage,temperature_std,'r--')
plt.scatter(output_voltage,temperature_std,c='b',s=13)
plt.title("Std. Deviations' of 100 Temperature Measurements")
plt.xlabel("Applied Voltage [V]")
plt.ylabel("Measured Temperature Std. Dev. [Celsius]")
plt.draw()
plt.savefig('lab6_tsd_fitted.png', dpi=600)

# show all plots
plt.show()   

    
#%%
