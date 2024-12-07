import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Float "mo:base/Float";
import Int "mo:base/Int";
import Result "mo:base/Result";

actor VotingSystem {
    /// Form: Oy verme işlemi için kullanılan veri modeli
    private type Vote = {
        adiniz: Text;
        soyadiniz: Text;
        eposta: Text;
        puan: Nat;
    };

    /// Hata mesajları için kullanılan veri modeli
    private type Error = {
        #NotFound;
        #AlreadyExists;
        #Invalidpuan;
    };

    // Oy verilerini saklayan veri tabanı
    private var votes = HashMap.HashMap<Principal, Vote>(0, Principal.equal, Principal.hash);

    /// Kullanıcının oy göndermesi için fonksiyon
    public shared(msg) func submitVote(
        adiniz: Text,
        soyadiniz: Text,
        eposta: Text,
        puan: Nat
    ) : async Result.Result<Text, Error> {
        if (puan < 1 or puan > 5) {
            return #err(#Invalidpuan);
        };

        let vote: Vote = {
            adiniz = adiniz;
            soyadiniz = soyadiniz;
            eposta = eposta;
            puan = puan;
        };

        votes.put(msg.caller, vote);
        return #ok("Oy başarıyla kaydedildi!");
    };

    /// Ortalama puanı hesaplama
    public query func getAveragepuan() : async Float {
        let iter = votes.vals();
        let array = Iter.toArray<Vote>(iter);
        var sum: Int = 0;
        for (vote in array.vals()) {
            sum += vote.puan;
        };
        let count = array.size();
        if (count == 0) { return 0.0 };
        Float.fromInt(sum) / Float.fromInt(count)
    };

    /// Toplam oy sayısını alma
    public query func getVoteCount() : async Nat {
        Iter.size(votes.entries())
    };

    /// En yüksek puanı alma
    public query func getHighestpuan() : async ?Nat {
        let iter = votes.vals();
        let array = Iter.toArray<Vote>(iter);
        if (array.size() == 0) { return null };

        var max = 0;
        for (vote in array.vals()) {
            if (vote.puan > max) {
                max := vote.puan;
            };
        };
        ?max
    };

    /// En düşük puanı alma
    public query func getLowestpuan() : async ?Nat {
        let iter = votes.vals();
        let array = Iter.toArray<Vote>(iter);
        if (array.size() == 0) { return null };

        var min = 5;
        for (vote in array.vals()) {
            if (vote.puan < min) {
                min := vote.puan;
            };
        };
        ?min
    };
};