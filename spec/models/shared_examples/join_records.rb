shared_examples 'something that has join records' do
  let(:klass) { described_class.to_s.underscore.to_sym }
  let(:record) { Factory(klass) }

  described_class.reflect_on_all_associations(:has_many).each do |association|
    next unless association.options[:through]

    context "for the #{association.name} association" do
      let(:associated) { Factory(association.name.to_s.singularize) }

      it "must clear join records on destruction" do
        record.send(association.name) << associated
        record.reload and associated.reload

        record.destroy
        expect { associated.reload }.not_to raise_error
        expect(associated.send(described_class.to_s.underscore.pluralize)).not_to include(record)
      end
    end
  end
end
