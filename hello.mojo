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

comptime JOBS_PER_CORE = 3


@fieldwise_init
struct Result(Copyable, ImplicitlyCopyable):
    var sum: Int64
    var median: Int64
    var max: Int64
    var min: Int64

    @staticmethod
    fn create_default() -> Result:
        return Result(0,0,0,0)

    fn merge_into(mut self, merge_with: Result):
        self.sum += merge_with.sum

        var max_is_unset = 0
        var min_is_unset = 0

        if max_is_unset or merge_with.max > self.max:
            self.max = merge_with.max

        if min_is_unset or merge_with.min < self.min:
            self.min = merge_with.min

struct SingleDiceBatch:
    var modes: List[StaticString]
    var sides: Int8
    var rolls: Int64


fn main():
    print("Hello, World!")

    var modes = [MODE_SUM, MODE_MIN, MODE_MAX]
    var dice_results = roll_dice(modes, 6, 100)
    print("Sum: ", dice_results.sum, "Max: ", dice_results.max)

    var final_result = batch_roll_dice(modes, 6, 40000000)
    print("sum is ", final_result.sum)



fn batch_roll_dice(mode: List[StaticString], sides: Int8, num: Int64) -> Result:
    var cores = num_physical_cores()
    var jobs_to_spawn = cores * JOBS_PER_CORE
    var number_of_dice_per_job = get_number_of_dice_per_job(
        num, Int64(jobs_to_spawn)
    )

    var results: List[Result] = []

    var perfectly_divided_job_dice = number_of_dice_per_job[0]
    var remaining_dice = number_of_dice_per_job[1]

    for _ in range(jobs_to_spawn):
        results.append(Result(0, 0, 0, 0))

    @parameter
    fn roll_dice_in_batch(worker_id: Int):
        var result = roll_dice(mode, sides, perfectly_divided_job_dice)
        results[worker_id] = result

    parallelize[roll_dice_in_batch](jobs_to_spawn)

    if remaining_dice == 0:
        return merge_results(results)
    else:
        # We have to roll the last batch of work seperately as it is the 
        # left_over dice that didn't fit evenly into the other jobs
        last_result_using_remaining_dice = Optional(roll_dice(mode, sides, remaining_dice)) 
        return merge_results(results, last_result_using_remaining_dice)

fn merge_results(results: List[Result], final_result: Optional[Result] = None) -> Result:

    var combined_result = Result.create_default()

    for result in results:
        combined_result.merge_into(result)

    if final_result:
        combined_result.merge_into(final_result.value())

    return combined_result


fn get_number_of_dice_per_job(num: Int64, jobs: Int64) -> Tuple[Int64, Int64]:
    var lowest_num_of_dice = num // JOBS_PER_CORE
    var remainder_of_dice = num % JOBS_PER_CORE

    return (lowest_num_of_dice, remainder_of_dice)


fn roll_dice(mode: List[StaticString], sides: Int8, num: Int64) -> Result:
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
