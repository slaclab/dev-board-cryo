import pyrogue as pr

# Modules from surf
import pyrogue as pr
import surf.axi as axi
import surf.devices.micron as micron
import surf.devices.microchip as microchip
import surf.devices.ti as ti
import surf.ethernet.udp as udp
import surf.misc as misc
import surf.protocols.rssi as rssi
import surf.xilinx as xilinx

# AmcCarrierCore
from AmcCarrierCore import *

from DevBoardUtils import *

# Modules from AppMps
from AppMps.AppMps import *


class LocReg(pr.Device):
    def __init__(   self, 
            name                = "LocReg", 
            description         = "AmcCarrierCore", 
            hidden              = False, 
            expand              = False,
            **kwargs):
        super().__init__(name=name, description=description, expand=expand, **kwargs)  

        self.add(pr.RemoteVariable(
            name        = "RFREQRef",
            description = "Si570 Freq. Multiplier; Factory calibration",
            offset      = 0x00,
            bitSize     = 64,
            bitOffset   = 0,
            base        = pr.UInt, 
            mode        = "RO",
       ))

        self.add(pr.RemoteVariable(
            name        = "RFREQLcls1",
            description = "Si570 Freq. Multiplier; For LCLS1 Timing",
            offset      = 0x08,
            bitSize     = 64,
            bitOffset   = 0,
            base        = pr.UInt, 
            mode        = "RO",
       ))

        self.add(pr.RemoteVariable(
            name        = "RFREQLcls2",
            description = "Si570 Freq. Multiplier; For LCLS2 Timing",
            offset      = 0x10,
            bitSize     = 64,
            bitOffset   = 0,
            base        = pr.UInt, 
            mode        = "RO",
       ))

        self.add(pr.RemoteVariable(
            name        = "TimingTxReset",
            description = "Reset timing GTH tranceiver",
            offset      = 0x100,
            bitSize     = 1,
            bitOffset   = 1,
            base        = pr.UInt, 
            mode        = "RW",
       ))

        self.add(pr.RemoteVariable(
            name        = "Si570NewFreq",
            description = "Clear Si570 lock bit and set 'New Freq' in < 10ms",
            offset      = 0x100,
            bitSize     = 1,
            bitOffset   = 0,
            base        = pr.UInt, 
            mode        = "RW",
       ))

class SysReg(pr.Device):
    def __init__(   self, 
            name                = "SysReg", 
            description         = "AmcCarrierCore", 
            rssiNotInterlaved   = True,
            rssiInterlaved      = False,            
            enableBsa           = True,
            enableMps           = True,
            expand	            = False,
            **kwargs):
        super().__init__(name=name, description=description, expand=expand, **kwargs)  

        ##############################
        # Variables
        ##############################                        
        self.add(axi.AxiVersion(            
            offset       =  0x00000000, 
            expand       =  False
        ))

        self.add(xilinx.AxiSysMonUltraScale(   
            offset       =  0x02000000, 
            expand       =  False
        ))
        
        self.add(AmcCarrierTiming(
            offset       =  0x04000000, 
            expand       =  False,
        ))

        self.add(LocReg(
            offset       =  0x07000000, 
            expand       =  False,
        ))

        self.add(AmcCarrierBsa(   
            offset       =  0x08000000, 
            enableBsa    =  enableBsa,
            expand       =  False,
        ))
                            
        self.add(udp.UdpEngineClient(
            name         = "BpUdpCltApp",
            offset       =  0x09000000,
            description  = "Backplane UDP Client for Application ASYNC Messaging",
            expand       =  False,
        ))

        self.add(udp.UdpEngineServer(
            name         = "SwUdpSrv",
            offset       =  0x09000800,
            description  = "Backplane UDP Server: Xilinx XVC",
            expand       =  False,
        ))
        
        self.add(udp.UdpEngineServer(
            name         = "BpUdpSrvXvc",
            offset       =  0x09000808,
            description  = "Backplane UDP Server: FSBL Legacy SRPv0 register access",
            expand       =  False,
        )) 
        
        self.add(rssi.RssiCore(
            name         = "SwRssiServer",
            offset       =  0x09010000,
            description  = "Interleaved RSSI server",                                
            expand       =  False,                                    
        ))            

        self.add(AxiFanController(
            name         = "FanController",
            offset       =  0x0A000000,
        ))

    def writeBlocks(self, force=False, recurse=True, variable=None, checkEach=False):
        """
        Write all of the blocks held by this Device to memory
        """
        if not self.enable.get(): return

        # Process local blocks.
        if variable is not None:
            #variable._block.startTransaction(rogue.interfaces.memory.Write, check=checkEach)  # > 2.4.0
            variable._block.backgroundTransaction(rogue.interfaces.memory.Write)
        else:
            for block in self._blocks:
                if force or block.stale:
                    if block.bulkEn:
                        #block.startTransaction(rogue.interfaces.memory.Write, check=checkEach)  # > 2.4.0
                        block.backgroundTransaction(rogue.interfaces.memory.Write)

        # Process rest of tree
        if recurse:
            for key,value in self.devices.items():
                #value.writeBlocks(force=force, recurse=True, checkEach=checkEach)  # > 2.4.0
                value.writeBlocks(force=force, recurse=True)
                        
        # Retire any in-flight transactions before starting
        self._root.checkBlocks(recurse=True)
        
        for i in range(2):
            v = getattr(self.AmcCarrierBsa, 'BsaWaveformEngine[%i]'%i)
            v.WaveformEngineBuffers.Initialize()
        
        self.checkBlocks(recurse=True)
        
