from std.random import random_float64, random_si64, random_ui64, seed
from std.sys import num_physical_cores
from std.math import floor
from std.algorithm import parallelize

comptime START_AT_ONE = 1

# Temporary work around until enums are added
comptime MODE_SUM = "MODE_SUM"
comptime MODE_MEDIAN = "MODE_MEDIAN"
comptime MODE_MAX = "MODE_MAX"
comptime MODE_MIN = "MODE_MIN"

comptime JOBS_PER_CORE = 2


@fieldwise_init
struct Result(Copyable, ImplicitlyCopyable):
    var sum: Int64
    var median: Int64
    var max: Int64
    var min: Int64


struct SingleDiceBatch:
    var modes: List[StaticString]
    var sides: Int8
    var rolls: Int64


fn main():
    print("Hello, World!")

    var modes = [MODE_SUM, MODE_MIN, MODE_MAX]
    var dice_results = roll_dice(modes, 6, 100)
    print("Sum: ", dice_results.sum, "Max: ", dice_results.max)

    batch_roll_dice(modes, 6, 400)


fn batch_roll_dice(mode: List[StaticString], sides: Int8, num: Int16):
    var cores = num_physical_cores()
    var jobs_to_spawn = cores * JOBS_PER_CORE
    var number_of_dice_per_job = get_number_of_dice_per_job(
        Int16(num), Int16(jobs_to_spawn)
    )

    var results: List[Result] = []

    var all_other_job_dice = number_of_dice_per_job[0]
    var one_job_dice = number_of_dice_per_job[1]

    for _ in range(jobs_to_spawn):
        results.append(Result(0, 0, 0, 0))

    @parameter
    fn roll_dice_in_batch(worker_id: Int):
        var result = roll_dice(mode, sides, all_other_job_dice)
        results[worker_id] = result

    print("entering parallel")
    parallelize[roll_dice_in_batch](jobs_to_spawn)

    print("result0 sum is ", len(results))


fn get_number_of_dice_per_job(num: Int16, jobs: Int16) -> Tuple[Int16, Int16]:
    var lowest_num_of_dice = num // JOBS_PER_CORE
    var remainder_of_dice = Int16(num % JOBS_PER_CORE)

    return (lowest_num_of_dice, remainder_of_dice)


fn roll_dice(mode: List[StaticString], sides: Int8, num: Int16) -> Result:
    var sum: Int64 = 0
    var median: Int64 = 0
    var max: Int64 = 0
    var min: Int64 = 0

    for _ in range(num):
        var roll = random(sides)

        if MODE_SUM in mode:
            sum += roll

        if MODE_MAX in mode:
            if roll > max:
                max = roll

        if MODE_MIN in mode:
            if roll < min:
                min = roll

    return Result(sum, median, max, min)


fn random(sides: Int8) -> Int64:
    seed()
    var rand = random_si64(START_AT_ONE, Int64(sides))
    return rand
