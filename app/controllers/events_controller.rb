class EventsController < ApplicationController

  authorize_resource

  # GET /events
  # GET /events.json
  def index
    @events = Event.chronological.paginate(:page => params[:page]).per_page(10)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end
  end

  # GET /events/1
  # GET /events/1.json
  def show
    @event = Event.find(params[:id])
    @attendance = EventAttendance.for_event(@event.id).paginate(:page => params[:page]).per_page(10)
    @exact_attendance = @event.take_attendance
    @present_events = @exact_attendance[0]
    @late_events = @exact_attendance[1]
    @absent_events = @exact_attendance[2]
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event }
    end
  end

  # GET /events/new
  # GET /events/new.json
  def new
    @event = Event.new
    @event.event_attendances.build
    @users = User.student
    authorize! :create, @event
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event }
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
    @users = User.student
    authorize! :update, @event
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(params[:event])
    @users = User.student
    authorize! :create, @event
    respond_to do |format|
      if @event.save
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render json: @event, status: :created, location: @event }
      else
        format.html { render action: "new" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    @event = Event.find(params[:id])
    @users = User.student
    authorize! :update, @event
    respond_to do |format|
      if @event.update_attributes(params[:event])
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event = Event.find(params[:id])
    @event.destroy
    authorize! :destroy, @event
    respond_to do |format|
      format.html { redirect_to events_url }
      format.json { head :no_content }
    end
  end
end
