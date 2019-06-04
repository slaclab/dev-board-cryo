#!/usr/bin/env python
#-----------------------------------------------------------------------------
# Title      : PyRogue AMC Carrier Cryo Demo Board Application
#-----------------------------------------------------------------------------
# File       : AppCore.py
# Created    : 2017-04-03
#-----------------------------------------------------------------------------
# Description:
# PyRogue AMC Carrier Cryo Demo Board Application
#-----------------------------------------------------------------------------
# This file is part of the rogue software platform. It is subject to
# the license terms in the LICENSE.txt file found in the top-level directory
# of this distribution and at:
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
# No part of the rogue software platform, including this file, may be
# copied, modified, propagated, or distributed except according to the terms
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------

import pyrogue as pr

from common.SimRtmCryoDet import *


class StreamData(pr.Device):
    def __init__(   self,
            name        = "StreamReg",
            description = "Stream control",
            **kwargs):
        super().__init__(name=name, description=description, **kwargs)
        #########
        # Devices
        for i in range(8):
           self.add(pr.RemoteVariable(
               name         = f'StreamData[{i}]',
               description  = "Dummy stream data",
               offset       = 0x000000 + i*0x2,
               bitSize      = 16,
               bitOffset    = 0,
               base         = pr.Int,
               mode         = "RW",
           ))

class StreamControl(pr.Device):
    def __init__(   self,
            name        = "StreamControl",
            description = "Stream control",
            **kwargs):
        super().__init__(name=name, description=description, **kwargs)
        #########
        # Devices
        self.add(pr.RemoteVariable(
            name         = "EnableStreams",
            description  = "EnableStream",
            offset       = 0x00000008,
            bitSize      = 1,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RW",
        ))

        self.add(pr.RemoteVariable(
            name         = "StreamCounterRst",
            description  = "Reset stream counters",
            offset       = 0x00000008,
            bitSize      = 1,
            bitOffset    = 8,
            base         = pr.UInt,
            mode         = "RW",
        ))

        self.add(pr.RemoteVariable(
            name         = "EofeCounterRst",
            description  = "Reset stream EOFE",
            offset       = 0x00000008,
            bitSize      = 1,
            bitOffset    = 9,
            base         = pr.UInt,
            mode         = "RW",
        ))

        self.add(pr.RemoteVariable(
            name         = "InternalTriggerSel",
            description  = "Select internal trigger (0 selects EVR)",
            offset       = 0x00000008,
            bitSize      = 1,
            bitOffset    = 10,
            base         = pr.UInt,
            mode         = "RW",
        ))


        self.add(pr.RemoteVariable(
            name         = "StreamCounter",
            description  = "Count number of stream triggers",
            offset       = 0x0000000C,
            bitSize      = 32,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RO",
            pollInterval = 1,
        ))

        self.add(pr.RemoteVariable(
            name         = "EofeCounter",
            description  = "Stream EOFE counter",
            offset       = 0x00000010,
            bitSize      = 32,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RO",
            pollInterval = 1,
        ))

class TimingHeader(pr.Device):
    def __init__(   self,
            name        = "TimingHeader",
            description = "Timing header status and config",
            **kwargs):
        super().__init__(name=name, description=description, **kwargs)
        #########
        for i in range(12):
            self.add(pr.RemoteVariable(
                name         = f'rtmDacConfig[{i}]',
                description  = "RTM DAC configuration",
                offset       = 0x00000000 + 0x4*i,
                bitSize      = 32,
                bitOffset    = 0,
                base         = pr.UInt,
                mode         = "RW",
            ))

        self.add(pr.RemoteVariable(
            name         = "fluxRampStepSize",
            description  = "flux ramp step size",
            offset       = 0x00000030,
            bitSize      = 32,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RW",
        ))


        self.add(pr.RemoteVariable(
            name         = "fluxRampResetValue",
            description  = "flux ramp reset value",
            offset       = 0x00000034,
            bitSize      = 32,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RW",
        ))


        for i in range(2):
            self.add(pr.RemoteVariable(
                name         = f'tesRelayConfig[{i}]',
                description  = "TES relay configuration",
                offset       = 0x00000038 + 0x4*i,
                bitSize      = 32,
                bitOffset    = 0,
                base         = pr.UInt,
                mode         = "RW",
            ))

        self.add(pr.RemoteVariable(
            name         = "timingConfig",
            description  = "timing config",
            offset       = 0x00000040,
            bitSize      = 8,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RW",
        ))

        self.add(pr.RemoteVariable(
            name         = "slotNumber",
            description  = "IPMI BSI slot number",
            offset       = 0x00000044,
            bitSize      = 8,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RW",
        ))

        self.add(pr.RemoteVariable(
            name         = "crateId",
            description  = "IPMI BSI crate ID",
            offset       = 0x00000048,
            bitSize      = 16,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RW",
        ))

        for i in range(6):
            self.add(pr.RemoteVariable(
                name         = f'userConfig[{i}]',
                description  = "User configuration",
                offset       = 0x00000050 + 0x4*i,
                bitSize      = 32,
                bitOffset    = 0,
                base         = pr.UInt,
                mode         = "RW",
            ))


        self.add(pr.RemoteVariable(
            name         = "errorCounterReset",
            description  = "Error counter reset",
            offset       = 0x0000004C,
            bitSize      = 1,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RW",
        ))

        self.add(pr.RemoteVariable(
            name         = "errorCounter",
            description  = "Error counter",
            offset       = 0x00000070,
            bitSize      = 32,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RO",
            pollInterval = 1,
        ))

        self.add(pr.RemoteVariable(
            name         = "timingValid",
            description  = "timing valid",
            offset       = 0x00000074,
            bitSize      = 1,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RO",
            pollInterval = 1,
        ))

        self.add(pr.RemoteVariable(
            name         = "timingExtnValid",
            description  = "timing extension valid",
            offset       = 0x00000074,
            bitSize      = 1,
            bitOffset    = 1,
            base         = pr.UInt,
            mode         = "RO",
            pollInterval = 1,
        ))

        for i in range(2):
            self.add(pr.RemoteVariable(
                name         = f'timestamp[{i}]',
                description  = "timing system timestamp",
                offset       = 0x00000078 + 0x4*i,
                bitSize      = 32,
                bitOffset    = 0,
                base         = pr.UInt,
                mode         = "RO",
                pollInterval = 1,
            ))

        self.add(pr.RemoteVariable(
            name         = "baseRateSince1Hz",
            description  = "ticks since 1Hz marker",
            offset       = 0x00000080,
            bitSize      = 32,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RO",
            pollInterval = 1,
        ))

        self.add(pr.RemoteVariable(
            name         = "baseRateSinceTM",
            description  = "base rate since timing marker",
            offset       = 0x00000084,
            bitSize      = 32,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RO",
            pollInterval = 1,
        ))

        self.add(pr.RemoteVariable(
            name         = "mceData",
            description  = "MCE data",
            offset       = 0x00000088,
            bitSize      = 40,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RO",
            pollInterval = 1,
        ))

        self.add(pr.RemoteVariable(
            name         = "fixedRates",
            description  = "fixedRates",
            offset       = 0x00000090,
            bitSize      = 10,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RO",
            pollInterval = 1,
        ))


class AppCore(pr.Device):
    def __init__(   self,
            name        = "AppCore",
            description = "MicrowaveMux Application",
            numRxLanes  =  [0,0],
            numTxLanes  =  [0,0],
            **kwargs):
        super().__init__(name=name, description=description, **kwargs)
        #########
        # Devices
        #########        
#        for i in range(2):
#            if ((numRxLanes[i] > 0) or (numTxLanes[i] > 0)):
#                self.add(AmcMicrowaveMuxCore(
#                    name    = "MicrowaveMuxCore[%i]" % (i),
#                    offset  = (i*0x00100000),
#                    expand  = True,
#                ))
#
#        self.add(SysgenCryo(offset=0x01000000, expand=True))

        self.add(SimRtmCryoDet(        offset=0x02000000, expand=False))

        ###########
        # Registers
        ###########        
        self.add(pr.RemoteVariable(
            name         = "DacSigTrigDelay",
            description  = "DacSig TrigDelay",
            offset       = 0x03000000,
            bitSize      = 24,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "RW",
            units        = "1/(307MHz)",
        ))

        self.add(pr.RemoteVariable(
            name         = "DacSigTrigArm",
            description  = "DacSig TrigArm",
            offset       = 0x03000004,
            bitSize      = 1,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = "WO",
            hidden       = True,
        ))

        self.add(StreamControl(
           offset=0x03000000, 
        ))

        self.add(TimingHeader(
           offset=0x04000000, 
        ))

        self.add(StreamData(
           offset=0x05000000, 
           expand=False,
        ))

        ##############################
        # Commands
        ##############################
        @self.command(description="Arms for a DAC SIG Trigger to the DAQ MUX",)
        def CmdDacSigTrigArm():
            self.DacSigTrigArm.set(1)

