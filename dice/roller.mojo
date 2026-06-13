from std.random import random_float64, random_si64, random_ui64, seed
from types.Result import Result
from types.enMode import enMode

comptime START_AT_ONE = 1

fn roll_dice(mode: List[StaticString], sides: Int8, num: Int64) -> Result:
    var sum: Int64 = 0
    var median: Int64 = 0
    var max: Int64 = 0
    var min: Int64 = 0

    for _ in range(num):
        var roll = random(sides)

        if enMode.MODE_SUM in mode:
            sum += roll

        if enMode.MODE_MAX in mode:
            if roll > max:
                max = roll

        if enMode.MODE_MIN in mode:
            if roll < min:
                min = roll

    return Result(sum, median, max, min)


fn random(sides: Int8) -> Int64:
    seed()
    var rand = random_si64(START_AT_ONE, Int64(sides))
    return rand
