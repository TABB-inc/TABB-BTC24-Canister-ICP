import Nat "mo:base/Nat";
import Array "mo:base/Array";
import Float "mo:base/Float";

persistent actor Main {

  public type User = {
    tg_user_id: Text;
    name: Text;
    total_predictions: Nat;
    successful_predictions: Nat;
  };

  public type LeaderboardEntry = {
    tg_user_id: Text;
    name: Text;
    success_rate: Float;
    total_predictions: Nat;
  };

  transient var users: [var User] = [var];

  public func addOrUpdateUser(user: User) : async () {

      func findUserIndex(arr: [User], pred: User -> Bool) : ?Nat {
        var i : Nat = 0;
        let n = arr.size();
        while (i < n) {
          if (pred(arr[i])) { return ?i };
          i += 1;
        };
      return null;
      };

    switch (findUserIndex(Array.freeze(users), func(u) { u.tg_user_id == user.tg_user_id })) {
      case (?idx) { users[idx] := user };
      case null { users := Array.thaw(Array.append(Array.freeze(users), [user])); };
    };
  };

  public func getUsers() : async [User] {
    return Array.freeze(users);
  };

  public func leaderboard(n: Nat) : async [LeaderboardEntry] {
    var lb: [var LeaderboardEntry] = Array.thaw(Array.map<User, LeaderboardEntry>(Array.freeze(users), func(u) {
      let rate = if (u.total_predictions == 0) 0.0 else Float.fromInt(u.successful_predictions) / Float.fromInt(u.total_predictions) * 100;
      { name = u.name; success_rate = rate; total_predictions = u.total_predictions; tg_user_id = u.tg_user_id }
    }));

    Array.sortInPlace<LeaderboardEntry>(
      lb,
      func(a, b) {
        if (Float.greater(a.success_rate, b.success_rate)) { #less }
        else if (Float.less(a.success_rate, b.success_rate)) { #greater }
        else { #equal }
      }
    );

    let count = if (n < lb.size()) n else lb.size();
    let topN = Array.subArray(Array.freeze(lb), 0, count);

    return topN;
};

public func resetUsers() : async () {
    users := [var];
};

}

