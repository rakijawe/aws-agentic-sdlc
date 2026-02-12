package com.myorg.usermanagement.model.dto;

import java.util.List;

/**
 * DTO for profile update requests.
 */
public class ProfileUpdateRequest {
    
    private String title;
    private String firstName;
    private String lastName;
    private String gender;
    private Integer age;
    private String email;
    private String address;
    private List<String> preferences;
    
    // Constructors
    public ProfileUpdateRequest() {
    }
    
    // Getters and Setters
    public String getTitle() {
        return title;
    }
    
    public void setTitle(String title) {
        this.title = title;
    }
    
    public String getFirstName() {
        return firstName;
    }
    
    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }
    
    public String getLastName() {
        return lastName;
    }
    
    public void setLastName(String lastName) {
        this.lastName = lastName;
    }
    
    public String getGender() {
        return gender;
    }
    
    public void setGender(String gender) {
        this.gender = gender;
    }
    
    public Integer getAge() {
        return age;
    }
    
    public void setAge(Integer age) {
        this.age = age;
    }
    
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email;
    }
    
    public String getAddress() {
        return address;
    }
    
    public void setAddress(String address) {
        this.address = address;
    }
    
    public List<String> getPreferences() {
        return preferences;
    }
    
    public void setPreferences(List<String> preferences) {
        this.preferences = preferences;
    }
}
