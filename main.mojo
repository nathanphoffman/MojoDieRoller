from std.random import random_float64, random_si64, random_ui64, seed
from std.sys import num_physical_cores
from std.math import floor

from types.Result import Result
from dice.batch_roller import batch_roll_dice

from types.enMode import enMode

struct SingleDiceBatch:
    var modes: List[StaticString]
    var sides: Int8
    var rolls: Int64

fn main():
    print("Hello, World!")

    var modes = [enMode.MODE_SUM, enMode.MODE_MIN, enMode.MODE_MAX]
    #var dice_results = roll_dice(modes, 6, 100)
    #print("Sum: ", dice_results.sum, "Max: ", dice_results.max)

    var final_result = batch_roll_dice(modes, 6, 40000000)
    print("sum is ", final_result.sum)


