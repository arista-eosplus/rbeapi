RSpec.shared_examples 'a configurable entity' do |opts|

  before(:each) do
    allow(subject.node).to receive(:config)
  end

  applies_to = opts.fetch(:applies_to, [])
  if applies_to.include?(opts[:args[0,2]]) or applies_to.empty?
    context 'with node#config' do
      [:create, :delete, :default].each do |action|
        it "calls #{action} using #{opts[:args]}" do
          expect(subject.node).to receive(:config).with(opts[action])
          subject.send(action, *opts[:args])
        end
      end
    end
  end
end

RSpec.shared_examples 'a tristate attr' do |opts|

  before(:each) do
    allow(subject.node).to receive(:config)
  end

  applies_to = opts.fetch(:applies_to, [])
  if applies_to.include?(opts[:args[0,2]]) or applies_to.empty?
    context 'with node#config' do
      it "configures with #{opts[:name]}" do
        expect(subject.node).to receive(:config).with(opts[:config])
        subject.send(opts[:name], *opts[:args], value: opts[:value])
      end

      it "negates with #{opts[:name]}" do
        expect(subject.node).to receive(:config).with(opts[:negate])
        subject.send(opts[:name], *opts[:args])
      end

      it "defaults" do
        expect(subject.node).to receive(:config).with(opts[:default])
        subject.send(opts[:name], *opts[:args], default: true)
      end
    end
  end
end

RSpec.shared_examples 'a settable attr' do |opts|

  before(:each) do
    allow(subject.node).to receive(:config)
  end

  context 'with node#config' do
    it "configures with #{opts[:name]}" do
      expect(subject.node).to receive(:config).with(opts[:config])
      subject.send(opts[:name], *opts[:args])
    end
  end
end

RSpec.shared_examples 'a creatable entity' do |args, setup, block|

  before(:each) do
    subject.node.config(setup)
  end

  context 'with node#config' do
    it "calls #create with #{args}" do
      expect(subject.get_block(block)).to be_nil
      subject.create(*args)
      expect(subject.get_block(block)).not_to be_nil
    end
  end
end

RSpec.shared_examples 'a deletable entity' do |args, setup, block|

  before(:each) do
    subject.node.config(setup)
  end

  context 'with node#config' do
    it "calls #delete with #{args}" do
      expect(subject.get_block(block)).not_to be_nil
      subject.delete(*args)
      expect(subject.get_block(block)).to be_nil
    end
  end
end

RSpec.shared_examples 'a configurable attr' do |opts|

  before(:each) do
    subject.node.config(opts[:setup])
  end

  context 'with node#config' do
    it "calls #{opts[:name]} with #{opts[:args]}" do
      expect(subject.get_block(opts[:block])).to match(opts[:before])
      subject.send(opts[:name], *opts[:args])
      expect(subject.get_block(opts[:block])).to match(opts[:after])
    end
  end
end

RSpec.shared_examples 'single entity' do |opts|

  describe 'match entity attributes from node' do
    let(:entity) { subject.get(opts[:args]) }
    opts[:entity].each do |key, value|
      it "has #{key} with #{value}" do
        binding.pry
        expect(entity[key]).to eq(value)
      end
    end
  end
end







