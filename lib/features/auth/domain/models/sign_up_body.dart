import 'package:ride_sharing_user_app/lib2/features/auth/domain/models/signup_body.dart';

class SignUpBody {
  String? fName;
  String? lName;
  String? phone;
  String? email;
  Gender? gender;
  String? password;
  String? confirmPassword;
  String? address;
  String? identificationType;
  String? identificationNumber;
  String? referralCode;

  SignUpBody(
      {this.fName,
      this.lName,
      this.phone,
      this.gender,
      this.email = '',
      this.password,
      this.confirmPassword,
      this.referralCode});

  SignUpBody.fromJson(Map<String, dynamic> json) {
    fName = json['first_name'];
    lName = json['last_name'];
    phone = json['phone'];
    password = json['password'];
    confirmPassword = json['confirm_password'];
    referralCode = json['referral_code'];
    gender = json['gender'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['first_name'] = fName;
    data['last_name'] = lName;
    data['phone'] = phone;
    data['password'] = password;
    data['confirm_password'] = confirmPassword;
    data['referral_code'] = referralCode;
    data['gender'] = gender?.name;
    return data;
  }
}

enum Gender { male, female }
