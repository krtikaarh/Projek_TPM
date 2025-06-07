import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/pet_model.dart';
import '../models/notification_model.dart';

class StorageService {
  static const String _petsKey = 'pets';
  static const String _notificationsKey = 'notifications';
  static const String _settingsKey = 'settings';

  // Pet Storage
  static Future<List<Pet>> loadPets() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> petStrings = prefs.getStringList(_petsKey) ?? [];
      return petStrings.map((str) => Pet.fromJson(json.decode(str))).toList();
    } catch (e) {
      print('Error loading pets: $e');
      return [];
    }
  }

  static Future<void> savePets(List<Pet> pets) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> petStrings = 
          pets.map((pet) => json.encode(pet.toJson())).toList();
      await prefs.setStringList(_petsKey, petStrings);
    } catch (e) {
      print('Error saving pets: $e');
    }
  }

  static Future<void> savePet(Pet pet) async {
    List<Pet> pets = await loadPets();
    int index = pets.indexWhere((p) => p.id == pet.id);
    
    if (index >= 0) {
      pets[index] = pet;
    } else {
      pets.add(pet);
    }
    
    await savePets(pets);
  }

  static Future<void> deletePet(String petId) async {
    List<Pet> pets = await loadPets();
    pets.removeWhere((pet) => pet.id == petId);
    await savePets(pets);
  }

  // Notification Storage
  static Future<List<NotificationModel>> loadNotifications() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> notificationStrings = 
          prefs.getStringList(_notificationsKey) ?? [];
      return notificationStrings
          .map((str) => NotificationModel.fromJson(json.decode(str)))
          .toList();
    } catch (e) {
      print('Error loading notifications: $e');
      return [];
    }
  }

  static Future<void> saveNotifications(List<NotificationModel> notifications) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> notificationStrings = notifications
          .map((notification) => json.encode(notification.toJson()))
          .toList();
      await prefs.setStringList(_notificationsKey, notificationStrings);
    } catch (e) {
      print('Error saving notifications: $e');
    }
  }

  // Settings Storage
  static Future<bool> getNotificationsEnabled() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true;
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
  }

  static Future<String> getThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('theme_mode') ?? 'system';
  }

  static Future<void> setThemeMode(String mode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode);
  }

  static Future<String> getLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('language') ?? 'id';
  }

  static Future<void> setLanguage(String language) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
  }
}
