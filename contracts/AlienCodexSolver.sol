// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

// 1) From the decomplied code below, or using web3.eth.getStorageAt(), confirmed that "owner" is stored in slot 0, together with the "contact" flag
// 2) Use retract() to underflow the codex counter, so that the array size becomes max(uint256) (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
// 3) It's easy to find out that codex is stored in slot 1, so the location of codex[0] is web3.utils.soliditySha3([slotNumber]) for dynamic arrays
// Reference:  https://medium.com/coinmonks/decoding-the-memory-of-an-ethereum-contract-52c256f83f07 
// and https://medium.com/@dariusdev/how-to-read-ethereum-contract-storage-44252c8af925
// 4) The storage slot of codex[N] is web3.utils.soliditySha3(1) + N, now we just need to basic maths to figure out N so that:
//    web3.utils.soliditySha3(1) + N == 0 (overflowing)
// This will give us access to write to slot 0
// 5) Slot 0 is 32 bytes while player address is 20 bytes, so we need to pad it with 12 bytes of 0 (24 times of '0' in the hex string)
// 6) Send the calculated N and the padded player address to revise()
// Notes: bytes32 is the same size as uint256, also the same size as one memory slot

contract AlienCodexDecompiled {
    function main() {
        memory[0x40:0x60] = 0x80;
        var var0 = msg.value;
    
        if (var0) { revert(memory[0x00:0x00]); }
    
        if (msg.data.length < 0x04) { revert(memory[0x00:0x00]); }
    
        var0 = msg.data[0x00:0x20] / 0x0100000000000000000000000000000000000000000000000000000000;
    
        if (0x8da5cb5b > var0) {
            if (var0 == 0x0339f300) {
                // Dispatch table entry for revise(uint256,bytes32)
                var var1 = 0x00f6;
                var var2 = 0x04;
                var var3 = msg.data.length - var2;
            
                if (var3 < 0x40) { revert(memory[0x00:0x00]); }
            
                revise(var2, var3);
                stop();
            } else if (var0 == 0x33a8c45a) {
                // Dispatch table entry for contact()
                var1 = 0x0100;
                var2 = contact();
                var temp0 = memory[0x40:0x60];
                memory[temp0:temp0 + 0x20] = !!var2;
                var temp1 = memory[0x40:0x60];
                return memory[temp1:temp1 + (temp0 + 0x20) - temp1];
            } else if (var0 == 0x47f57b32) {
                // Dispatch table entry for retract()
                var1 = 0x0122;
                retract();
                stop();
            } else if (var0 == 0x58699c55) {
                // Dispatch table entry for make_contact()
                var1 = 0x012c;
                make_contact();
                stop();
            } else if (var0 == 0x715018a6) {
                // Dispatch table entry for renounceOwnership()
                var1 = 0x0136;
                renounceOwnership();
                stop();
            } else { revert(memory[0x00:0x00]); }
        } else if (var0 == 0x8da5cb5b) {
            // Dispatch table entry for owner()
            var1 = 0x0140;
            var1 = owner();
            var temp2 = memory[0x40:0x60];
            memory[temp2:temp2 + 0x20] = var1 & 0xffffffffffffffffffffffffffffffffffffffff;
            var temp3 = memory[0x40:0x60];
            return memory[temp3:temp3 + (temp2 + 0x20) - temp3];
        } else if (var0 == 0x8f32d59b) {
            // Dispatch table entry for isOwner()
            var1 = 0x018a;
            var1 = isOwner();
            var temp4 = memory[0x40:0x60];
            memory[temp4:temp4 + 0x20] = !!var1;
            var temp5 = memory[0x40:0x60];
            return memory[temp5:temp5 + (temp4 + 0x20) - temp5];
        } else if (var0 == 0x94bd7569) {
            // Dispatch table entry for codex(uint256)
            var1 = 0x01d0;
            var2 = 0x04;
            var3 = msg.data.length - var2;
        
            if (var3 < 0x20) { revert(memory[0x00:0x00]); }
        
            var2 = codex(var2, var3);
            var temp6 = memory[0x40:0x60];
            memory[temp6:temp6 + 0x20] = var2;
            var temp7 = memory[0x40:0x60];
            return memory[temp7:temp7 + (temp6 + 0x20) - temp7];
        } else if (var0 == 0xb5c645bd) {
            // Dispatch table entry for record(bytes32)
            var1 = 0x0212;
            var2 = 0x04;
            var3 = msg.data.length - var2;
        
            if (var3 < 0x20) { revert(memory[0x00:0x00]); }
        
            record(var2, var3);
            stop();
        } else if (var0 == 0xf2fde38b) {
            // Dispatch table entry for transferOwnership(address)
            var1 = 0x0256;
            var2 = 0x04;
            var3 = msg.data.length - var2;
        
            if (var3 < 0x20) { revert(memory[0x00:0x00]); }
        
            transferOwnership(var2, var3);
            stop();
        } else { revert(memory[0x00:0x00]); }
    }
    
    function revise(var arg0, var arg1) {
        var temp0 = arg0;
        arg0 = msg.data[temp0:temp0 + 0x20];
        arg1 = msg.data[temp0 + 0x20:temp0 + 0x20 + 0x20];
    
        if (!(storage[0x00] / 0x0100 ** 0x14 & 0xff)) { assert(); }
    
        var var0 = arg1;
        var var1 = 0x01;
        var var2 = arg0;
    
        if (var2 >= storage[var1]) { assert(); }
    
        memory[0x00:0x20] = var1;
        storage[keccak256(memory[0x00:0x20]) + var2] = var0;
    }
    
    function codex(var arg0, var arg1) returns (var arg0) {
        arg0 = msg.data[arg0:arg0 + 0x20];
        arg1 = 0x01;
        var var0 = arg0;
    
        if (var0 >= storage[arg1]) { assert(); }
    
        memory[0x00:0x20] = arg1;
        return storage[keccak256(memory[0x00:0x20]) + var0];
    }
    
    function record(var arg0, var arg1) {
        arg0 = msg.data[arg0:arg0 + 0x20];
    
        if (!(storage[0x00] / 0x0100 ** 0x14 & 0xff)) { assert(); }
    
        var temp0 = storage[0x01] + 0x01;
        storage[0x01] = temp0;
        memory[0x00:0x20] = 0x01;
        storage[keccak256(memory[0x00:0x20]) + (temp0 - 0x01)] = arg0;
    }
    
    function transferOwnership(var arg0, var arg1) {
        arg0 = msg.data[arg0:arg0 + 0x20] & 0xffffffffffffffffffffffffffffffffffffffff;
        arg1 = 0x051f;
        arg1 = isOwner();
    
        if (arg1) {
            arg1 = 0x059c;
            var var0 = arg0;
            func_059F(var0);
            return;
        } else {
            var temp0 = memory[0x40:0x60];
            memory[temp0:temp0 + 0x20] = 0x08c379a000000000000000000000000000000000000000000000000000000000;
            var temp1 = temp0 + 0x04;
            var temp2 = temp1 + 0x20;
            memory[temp1:temp1 + 0x20] = temp2 - temp1;
            memory[temp2:temp2 + 0x20] = 0x20;
            var temp3 = temp2 + 0x20;
            memory[temp3:temp3 + 0x20] = 0x4f776e61626c653a2063616c6c6572206973206e6f7420746865206f776e6572;
            var temp4 = memory[0x40:0x60];
            revert(memory[temp4:temp4 + (temp3 + 0x20) - temp4]);
        }
    }
    
    function contact() returns (var r0) { return storage[0x00] / 0x0100 ** 0x14 & 0xff; }
    
    function retract() {
        if (!(storage[0x00] / 0x0100 ** 0x14 & 0xff)) { assert(); }
    
        var var0 = storage[0x01];
        var var1 = 0x02d2;
        var var2 = 0x01;
        var var3 = var0 - 0x01;
        func_06E5(var2, var3);
    }
    
    function make_contact() {
        storage[0x00] = (storage[0x00] & ~(0xff * 0x0100 ** 0x14)) | 0x0100 ** 0x14;
    }
    
    function renounceOwnership() {
        var var0 = 0x02fa;
        var0 = isOwner();
    
        if (var0) {
            var temp0 = memory[0x40:0x60];
            log(memory[temp0:temp0 + memory[0x40:0x60] - temp0], [0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0, storage[0x00] & 0xffffffffffffffffffffffffffffffffffffffff, 0xffffffffffffffffffffffffffffffffffffffff & 0x00]);
            storage[0x00] = (storage[0x00] & ~0xffffffffffffffffffffffffffffffffffffffff) | 0x00;
            return;
        } else {
            var temp1 = memory[0x40:0x60];
            memory[temp1:temp1 + 0x20] = 0x08c379a000000000000000000000000000000000000000000000000000000000;
            var temp2 = temp1 + 0x04;
            var temp3 = temp2 + 0x20;
            memory[temp2:temp2 + 0x20] = temp3 - temp2;
            memory[temp3:temp3 + 0x20] = 0x20;
            var temp4 = temp3 + 0x20;
            memory[temp4:temp4 + 0x20] = 0x4f776e61626c653a2063616c6c6572206973206e6f7420746865206f776e6572;
            var temp5 = memory[0x40:0x60];
            revert(memory[temp5:temp5 + (temp4 + 0x20) - temp5]);
        }
    }
    
    function owner() returns (var r0) { return storage[0x00] & 0xffffffffffffffffffffffffffffffffffffffff; }
    
    function isOwner() returns (var r0) { return msg.sender == storage[0x00] & 0xffffffffffffffffffffffffffffffffffffffff; }
    
    function func_059F(var arg0) {
        if (arg0 & 0xffffffffffffffffffffffffffffffffffffffff != 0xffffffffffffffffffffffffffffffffffffffff & 0x00) {
            var temp0 = arg0;
            var temp1 = memory[0x40:0x60];
            log(memory[temp1:temp1 + memory[0x40:0x60] - temp1], [0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0, storage[0x00] & 0xffffffffffffffffffffffffffffffffffffffff, stack[-1] & 0xffffffffffffffffffffffffffffffffffffffff]);
            storage[0x00] = (temp0 & 0xffffffffffffffffffffffffffffffffffffffff) | (storage[0x00] & ~0xffffffffffffffffffffffffffffffffffffffff);
            return;
        } else {
            var temp2 = memory[0x40:0x60];
            memory[temp2:temp2 + 0x20] = 0x08c379a000000000000000000000000000000000000000000000000000000000;
            var temp3 = temp2 + 0x04;
            var temp4 = temp3 + 0x20;
            memory[temp3:temp3 + 0x20] = temp4 - temp3;
            memory[temp4:temp4 + 0x20] = 0x26;
            var temp5 = temp4 + 0x20;
            memory[temp5:temp5 + 0x26] = code[0x0737:0x075d];
            var temp6 = memory[0x40:0x60];
            revert(memory[temp6:temp6 + (temp5 + 0x40) - temp6]);
        }
    }
    
    function func_06E5(var arg0, var arg1) {
        var temp0 = arg0;
        var temp1 = storage[temp0];
        var var0 = temp1;
        var temp2 = arg1;
        storage[temp0] = temp2;
    
        if (var0 <= temp2) {
        label_070C:
            return;
        } else {
            memory[0x00:0x20] = arg0;
            var temp3 = keccak256(memory[0x00:0x20]);
            var temp4 = temp3 + var0;
            var0 = 0x070b;
            var var1 = temp4;
            var var2 = temp3 + arg1;
            var0 = func_0711(var1, var2);
            goto label_070C;
        }
    }
    
    function func_0711(var arg0, var arg1) returns (var r0) {
        var temp0 = arg0;
        arg0 = 0x0733;
        var temp1 = arg1;
        arg1 = temp0;
        var var0 = temp1;
    
        if (arg1 > var0) { return func_0720(arg1, var0); }
    
        arg0 = arg1;
        // Error: Could not resolve jump destination!
    }
    
    function func_0720(var arg0, var arg1) returns (var r0) {
        var temp0 = arg1;
        storage[temp0] = 0x00;
        arg1 = temp0 + 0x01;
    
        if (arg0 <= arg1) { return arg0; }
    
        r0 = func_0720(arg0, arg1);
        // Error: Could not resolve method call return address!
    }
}
