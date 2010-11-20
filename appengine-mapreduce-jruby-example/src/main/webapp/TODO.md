TODO
====

1. Simple create mapreduce job from DM Entity
> ScrapedPage.map(:to => ExtractedRecords, :async => true, :callback => url) do |k, v, ctx| # instead __ExtractedRecords__ DM Resource, we may use :extracted_records for non mapped entity, also we may skip this value by pass nil value then will generated random name and returned in map_to result. Maybe it should be like Future in __Java__.
>   require 'marathon_extractor'
>   records = MarathonExtractor.new.extract_records v.body
>   emit(k => records) # need to deep in Haddop
>   count(k1, k2, k3).increment # need get counts methods
> end # return MapReduce Job, where we can get properties and other.

2. Distributed invokation for MR Tasks
> __ExtractedRecords__ # remote repository on GAE by ProtoBuf
> ScrapedPage.map(:to => ExtractedRecords)

3. Also map should be invoked in QueryResult like __each__
