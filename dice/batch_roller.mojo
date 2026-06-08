from types.Result import Result
from std.algorithm import parallelize
from dice.roller import roll_dice
from std.sys import num_physical_cores
from types.Result import merge_results

comptime JOBS_PER_CORE = 3

fn batch_roll_dice(mode: List[StaticString], sides: Int8, num: Int64) -> Result:
    var cores = num_physical_cores()
    var jobs_to_spawn = cores * JOBS_PER_CORE
    var number_of_dice_per_job = get_number_of_dice_per_job(
        num, Int64(jobs_to_spawn)
    )

    var perfectly_divided_job_dice, remaining_dice = number_of_dice_per_job
    var results: List[Result] = []

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

fn get_number_of_dice_per_job(num: Int64, jobs: Int64) -> Tuple[Int64, Int64]:
    var lowest_num_of_dice = num // jobs
    var remainder_of_dice = num % jobs

    return (lowest_num_of_dice, remainder_of_dice)

