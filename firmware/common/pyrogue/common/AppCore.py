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

        for i in range(8):
           self.add(pr.RemoteVariable(
               name         = "f'EnableStream[{i}]'",
               description  = "EnableStream",
               offset       = 0x03000008,
               bitSize      = 1,
               bitOffset    = i,
               base         = pr.UInt,
               mode         = "RW",
           ))

        ##############################
        # Commands
        ##############################
        @self.command(description="Arms for a DAC SIG Trigger to the DAQ MUX",)
        def CmdDacSigTrigArm():
            self.DacSigTrigArm.set(1)

