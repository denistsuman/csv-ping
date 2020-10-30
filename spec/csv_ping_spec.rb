require_relative '../app/csv_ping'

describe CsvPing do

  let(:csv_path) { 'spec/fixtures/test.csv' }

  let(:local_success_response) { OpenStruct.new(status: [200, "OK"]) }
  let(:local_fail_response) { OpenStruct.new(status: [404, "Not Found"]) }
  let(:remote_success_response) do
    [
      [
        1,
        0.141490936279297,
        "Found",
        "200",
        "18.157.219.111"
      ]
    ]
  end
  let(:remote_fail_response) do
    [
      [
        0,
        0.141490936279297,
        "Not Found",
        "404",
        "18.157.219.111"
      ]
    ]
  end
  let(:expected_response) do
    {
      "locally_available.url" => true,
      "remotely_available.url" => true,
      "unavailable.url" => false
    }
  end

  before do
    allow_any_instance_of(Checker::Local).
      to receive(:open).with("http://locally_available.url").and_return(local_success_response)
    allow_any_instance_of(Checker::Local).
      to receive(:open).with("http://remotely_available.url").and_return(local_fail_response)
    allow_any_instance_of(Checker::Local).
      to receive(:open).with("http://unavailable.url").and_return(local_fail_response)

    allow_any_instance_of(Checker::Remote).
      to receive(:response).with("http://remotely_available.url").and_return(remote_success_response)
    allow_any_instance_of(Checker::Remote).
      to receive(:response).with("http://unavailable.url").and_return(remote_fail_response)
  end

  subject { described_class.new(csv_path).perform }

  it { is_expected.to eq expected_response }

end
