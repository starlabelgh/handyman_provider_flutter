import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/utils/colors.dart';

extension colorExt on String {
  Color get getPaymentStatusBackgroundColor {
    switch (this) {
      case "pending":
        return pending;
      case "accept":
        return accept;
      case "on_going":
        return on_going;
      case "in_progress":
        return in_progress;
      case "hold":
        return hold;
      case "cancelled":
        return cancelled;
      case "rejected":
        return rejected;
      case "failed":
        return failed;
      case "completed":
        return completed;

      default:
        return defaultStatus;
    }
  }

  Color get getBookingActivityStatusColor {
    switch (this) {
      case "add_booking":
        return add_booking;
      case "assigned_booking":
        return assigned_booking;
      case "transfer_booking Going":
        return transfer_booking;
      case "update_booking_status Progress":
        return update_booking_status;
      case "cancel_booking":
        return cancel_booking;
      case "payment_message_status":
        return payment_message_status;

      default:
        return defaultActivityStatus;
    }
  }

  Color get getWalletHistoryStatusColor {
    switch (this) {
      case "add_wallet":
        return add_wallet;
      case "update_wallet":
        return update_wallet;
      case "wallet_payout_transfer":
        return wallet_payout_transfer;
      default:
        return add_wallet;
    }
  }
}
