class UsersController < ApplicationController
  before_filter :check_user_status, :only => [:edit, :update]
  before_filter :is_owner, :only => [:edit, :update, :destroy]
  before_filter :check_account_creation_status, :only => [:new, :create]
  
  # Ensure that the current user is authorized to make changes
  def is_owner
    @user = User.find_by_login(params[:id])
    @user == current_user || access_denied
  end
  
  def check_account_creation_status
    unless ArchiveConfig.ACCOUNT_CREATION_ENABLED
      flash[:error] = "Account creation is suspended at the moment. Please check back with us later.".t
      redirect_to login_path 
    end
  end
  
  def index
    @users = User.alphabetical.paginate(:page => params[:page])
  end 

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find_by_login(params[:id])
    @works = @user.works.visible(current_user, {:limit => 5, :order => 'works.updated_at DESC'})
    @series = @user.series.find(:all, :limit => 5, :order => 'series.updated_at DESC')
    @bookmarks = @user.bookmarks.visible(current_user, {:limit => 5, :order => 'bookmarks.updated_at DESC'})
  end
  
  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new
  end
  
  # GET /users/1/edit
  def edit
    @user = User.find_by_login(params[:id])
  end
  
  # POST /users
  # POST /users.xml
  def create
    if params["cancel-create-account"] == "Cancel"
      redirect_to '/'
    else
      @user = User.new(params[:user])   
      if @user.save
        flash[:notice] = 'during testing you can activate via <a href=' + activate_path(@user.activation_code) + '>your activation url</a>.'
  
        render :partial => "confirmation", :layout => "application"
      else
        render :action => "new"
      end
    end
  end
  
  def activate
    if params[:id].blank?
      flash[:error] = "Your activation key is missing.".t
      redirect_to ''
    else
      @user = User.find_by_activation_code(params[:id])
      if @user
        @user.activate
        self.current_user = @user
        flash[:notice] = "Signup complete! This is your public profile.".t
        redirect_to(@user)
      else
        flash[:error] = "Your activation key is invalid. Perhaps it has expired.".t
        redirect_to '' 
      end
    end
  end
  
  def after_reset
    @user = User.find_by_login(params[:id])  
  end
  
  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find_by_login(params[:id])
    begin 
      if @user.profile
        @user.profile.update_attributes! params[:profile_attributes]
      else
        @user.profile = Profile.new(params[:profile_attributes])
        @user.profile.save!
      end
      @user.recently_reset = nil if params[:change_password] 
      @user.update_attributes!(params[:user]) 
      flash[:notice] = 'User was successfully updated.'.t
      redirect_to(@user) 
    rescue
      render :action => "edit"
    end
  end
  
  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find_by_login(params[:id])
    @user.destroy
    redirect_to(users_url) 
  end
  
  
end
