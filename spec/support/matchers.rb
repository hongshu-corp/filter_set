require 'slim'

RSpec::Matchers.define :eq_in_slim do |expected|
  match do |actual|
    @expected = Slim::Template.new do
      expected
    end.render
    @expected == actual
  end

  failure_message do |actual|
    message = "
    expected: #{@expected}
         got: #{actual}\n"
    message += "\nDiff:" + differ.diff_as_string(Nokogiri::XML(actual).to_xhtml(indent: 2) , Nokogiri::XML(@expected).to_xhtml(indent: 2))
    message
  end
end

def differ
  RSpec::Support::Differ.new(
    :object_preparer => lambda { |object| RSpec::Matchers::Composable.surface_descriptions_in(object) },
    :color => RSpec::Matchers.configuration.color?
  )
end
