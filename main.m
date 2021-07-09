%% Main for Computer Vision Project in SS21
% Moritz Schneider, Adam Misik, Onat Inak, Robert Jacumet
% Computer Vision Project SS21, Group 30

% Goal of the Project: Spot changes of places like glaciers, cities,
% rainforests over time to see their development. Therefore satelite images
% taken at different times are input to the GUI and differences are shown
% to the user, who can also choose parameters on:
% - Segmentation of specific image regions based on k-Means
% - Modes of visualization (historical timelapse, comparison timelapse, highlights visualization, two image comparison)
% - Magnitude of changes
% - Area of changes
% - Mark changes based on their intensity with the help of superpixels
% - Percentage of top differences in the highlights visualization mode

clear all
close all
clc

obj_GUI = GUI()


