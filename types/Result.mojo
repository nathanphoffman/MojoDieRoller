
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


fn merge_results(results: List[Result], final_result: Optional[Result] = None) -> Result:

    var combined_result = Result.create_default()

    for result in results:
        combined_result.merge_into(result)

    if final_result:
        combined_result.merge_into(final_result.value())

    return combined_result
