# -*- coding: utf-8 -*-

#%%
# import various libraries necessery to run your Python code
import time   # time related library
import sys    # system related library
ok_loc = 'C:\\Program Files\\Opal Kelly\\FrontPanelUSB\\API\\Python\\3.6\\Win32'
sys.path.append(ok_loc)   # add the path of the OK library
import ok     # OpalKelly library

#%%
# Define FrontPanel device variable, open USB communication and
# load the bit file in the FPGA
dev = ok.okCFrontPanel()  # define a device for FrontPanel communication
SerialStatus=dev.OpenBySerial("")      # open USB communicaiton with the OK board
ConfigStatus=dev.ConfigureFPGA("C:\\Users\\nlao2\\Lab2\\Lab2.runs\\impl_1\\lab2_example.bit"); # Configure the FPGA with this bit file

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
while (True):
    clkdivFreq = int(input("What value do you want the clock divider?\n"))
    if (clkdivFreq > 0 and clkdivFreq <= 4000000000):
        break
    print("\nInvalid value\n")

dev.SetWireInValue(0x00, clkdivFreq)
dev.UpdateWireIns()

while(True):
    time.sleep(1)
    dev.UpdateWireOuts()
    counter = dev.GetWireOutValue(0x20)
    print("The value of the counter is " + str(int(counter)))
    if (counter > 100):
        dev.SetWireInValue(0x01, 1)
        dev.UpdateWireIns()
        print("Resetting counter")
        time.sleep(clkdivFreq/200000000 + 0.0001)
    dev.SetWireInValue(0x01, 0)
    dev.UpdateWireIns()

dev.Close

#%%
