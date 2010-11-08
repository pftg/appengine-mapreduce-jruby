require File.join(File.dirname(__FILE__), '..', 'lib', 'marathon_extractor')

describe MarathonExtractor do
  describe "ODDS_MATCHER RegExp" do
    specs = [{
                     :game_data => " 03/11  <b id=r>1)\320\221\321\200\320\276\320\275\320\264\320\261\321\216</b>         <b> <span class=tk>2.44</span> </b>   <span class=tk>3.45</span>   <span class=tk>2.80</span>  <b>1.43 </b> 1.31  1.55  <b> 0.0=>1.80 </b>  0.0=>2.04  <b>  2.5 </b> 2.10  1.75\n 20:30  <b id=r>2)\320\255\320\262\320\265\321\200\321\202\320\276\320\275</b>\n".strip,
                     :expects => {
                             :date => '03/11',
                             :home => 'Брондбю',
                             :first => '2.44',
                             :draw => '3.45',
                             :second => '2.80'
                     }
             },
             {
                     :game_data => "\n 23/11  <b id=r>1)\320\247\320\265\320\273\321\201\320\270</b>             <b> <span class=tk>1.07</span> </b>  <span class=tk>12.00</span>  <span class=tk>25.00</span>  <b>     </b> 1.03  8.10  <b>-2.5=>1.91 </b> +2.5=>1.91  <b>  3.5 </b> 1.81  2.02\n 22:45  <b id=r>2)\320\226\320\270\320\273\320\270\320\275\320\260</b>\n".strip,
                     :expects => {
                             :date => '23/11',
                             :home => "\320\247\320\265\320\273\321\201\320\270",
                             :first => '1.07',
                             :draw => '12.00',
                             :second => '25.00'
                     }
             }
    ]

    specs.each do |spec|
      context "with game data: #{spec[:game_data]}" do

        game_data = spec[:game_data]
        expects = spec[:expects]

        it "should match date" do
          game_data.match(MarathonExtractor::DATE_EXP)[0].should == expects[:date]
          game_data.match(MarathonExtractor::DATE_EXP).offset(0).should == [0, 5]
        end

        it "should match date and home" do
          expr = "(?m:%s)" % [MarathonExtractor::DATE_EXP, MarathonExtractor::HOME_EXP].join(".*?")
          game_data.match(expr).should_not be_nil
        end

        it "should match date, home and first" do
          expr = "(?m:%s)" % [
                  MarathonExtractor::DATE_EXP,
                  MarathonExtractor::HOME_EXP,
                  MarathonExtractor::BOLD_ODD_EXP
          ].join(".*?")

          game_data.match(expr).captures.should == [expects[:date], expects[:home], expects[:first]]
        end

        it "should match date, home, first and draw" do
          expr = "(?m:%s)" % [
                  MarathonExtractor::DATE_EXP,
                  MarathonExtractor::HOME_EXP,
                  MarathonExtractor::FIRST_ODD_EXP,
                  MarathonExtractor::DRAW_AND_SECOND_ODDS_EXP
          ].join(".*?")

          game_data.match(expr).captures.should == [
                  expects[:date], expects[:home], expects[:first], expects[:draw], expects[:second]]
        end

        it "should match step by step" do
          p = {}
          p[:date] = MarathonExtractor::DATE_EXP
          p[:home] = MarathonExtractor::HOME_EXP
          p[:guest] = MarathonExtractor::GUEST_EXP
          p[:total] = p[:first_draw] = p[:first] = MarathonExtractor::BOLD_ODD_EXP
          p[:f1] = MarathonExtractor::BOLD_FORA_EXP
          p[:f2] = MarathonExtractor::FORA_2_EXP
          p[:time] = MarathonExtractor::TIME_EXP
          p[:less_more] = p[:first_second_and_second_draw] = p[:draw_and_second] = MarathonExtractor::UNITED_ODD_EXP

          matchers = [p[:date], p[:home], p[:first], p[:draw_and_second], p[:first_draw],
                      p[:first_second_and_second_draw], p[:f1], p[:f2], p[:total], p[:less_more],
                      p[:time], p[:guest]]

          matchers.inject([]) { |a, m|
            a << m
            expr = "(?m:%s)" % a.join(".*?")
            puts "Checking: #{expr} => #{game_data.match(expr)}"
            game_data.match(expr).should_not be_nil
            a
          }

        end

        it "should match all data" do
          game_data.match(MarathonExtractor::ODDS_MATCHER).captures
        end
      end
    end
  end

  describe '#extract_game_entity' do
    let(:game_data) { " 03/11  <b id=r>1)\320\221\321\200\320\276\320\275\320\264\320\261\321\216</b>         <b> <span class=tk>2.44</span> </b>   <span class=tk>3.45</span>   <span class=tk>2.80</span>  <b>1.43 </b> 1.31  1.55  <b> 0.0=>1.80 </b>  0.0=>2.04  <b>  2.5 </b> 2.10  1.75\n 20:30  <b id=r>2)\320\255\320\262\320\265\321\200\321\202\320\276\320\275</b>\n" }

    before(:all) {
      @extracted_records = subject.extract_game_entity(game_data)
    }

    it "should extract date" do
      @extracted_records[:date].should == '03/11'
    end

    it "should extract home" do
      @extracted_records[:home].should == "Брондбю"
    end

    it "should extract guest" do
      @extracted_records[:guest].should == "Эвертон"
    end

    it "should extract first" do
      @extracted_records[:first].should == "2.44"
    end
  end
end