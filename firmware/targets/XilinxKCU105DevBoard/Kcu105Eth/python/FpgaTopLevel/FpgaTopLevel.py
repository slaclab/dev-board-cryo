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

import AppTop as app

class FpgaTopLevel(app.TopLevel):
    def __init__( self, 
        simGui          = False,
        commType        = "pcie-rssi-interleaved",
        ipAddr          = "192.168.2.10",
        pcieRssiLink    = 5,
    ):
        super().__init__(
            simGui          = simGui,
            commType        = commType,
            ipAddr          = ipAddr,
            pcieRssiLink    = pcieRssiLink,              
            numRxLanes      = [0,0],      # 10x JESD  on BAY[0] only
            numTxLanes      = [0,0],      # 10x JESD  on BAY[0] only
            numSigGen       = [2,0],       # 2x SIGGEN on BAY[0] Only
            sizeSigGen      = [2**13,0],   # 2^12 buffer size for BAY[0] Only
            modeSigGen      = [True,False],# True = 32-bit RAM, True =16-bit RAM
            enableBsa       = False,       # BSA not built in FW
            enableMps       = False,       # MPS not built in FW
        )
        
