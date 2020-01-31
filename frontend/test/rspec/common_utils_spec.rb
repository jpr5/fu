describe "common/ruby/utils" do

    it "implements String.literalize" do
        expect("1".literalize).to be == 1

        expect("1.1".literalize - 1.1).to be < 0.01

        expect("true".literalize).to be == true
        expect("TRUE".literalize).to be == true
        expect("false".literalize).to be == false
        expect("FALSE".literalize).to be == false

        expect("nil".literalize).to be_nil

        expect(":".literalize).to be == ":"
        expect(":sym".literalize).to be == :sym

        expect("".literalize).to be == ""
        expect("test".literalize).to be == "test"
    end

    it "implements Array.literalize" do
        expect([].literalize).to be == []

        a = [ 'test', 1, true, nil, :sym ]
        expect(a.literalize).to be == a

        expect(%w{ test 1 true nil :sym }.literalize).to be == a
    end

    it "implements Hash.literalize" do
        expect({}.literalize).to be == {}

        h = {
            'String' => 'test',
            'Number' => 1,
            'Boolean' => true,
            'Nil' => nil,
            'Symbol' => :sym,
        }
        expect(h.literalize).to be == h

        expect({
            'String' => 'test',
            'Number' => '1',
            'Boolean' => 'true',
            'Nil' => 'nil',
            'Symbol' => ':sym',
        }.literalize).to be == h
    end

end
