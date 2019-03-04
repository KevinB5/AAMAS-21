package loadingdocks;

import java.awt.Color;
import java.awt.Point;
import loadingdocks.Block.Shape;

/**
 * Agent behavior
 * @author Rui Henriques
 */
public class Agent extends Entity {

	public int direction = 90;

	public Agent(Point point, Color color){ 
		super(point, color);
	} 
	
	
	/**********************
	 **** A: decision ***** 
	 **********************/
	
	public void agentDecision() {
		if(carryingBox() && boxAhead() && rampAhead()) {
		//	pickBox();
			rotate();
		}else if( carryingBox() && shelfAhead() && (color == colorAhead()) && boxAhead()) {
		//	dropBox();
			rotate();
		}else if (!isFreeCell() || isWall()) {
			rotate();
		}else {
			moveAhead();
		}
	}
	
	/********************/
	/**** B: sensors ****/
	/********************/
	
	/* Check if the cell ahead is floor (which means not a wall, not a shelf nor a ramp) and there are any robot there */
	protected boolean isFreeCell() {
	  Point ahead = aheadPosition();
	  return Board.getBlock(ahead).shape.equals(Shape.free);
	}

	protected boolean boxAhead() {
		  Point ahead = aheadPosition();
		  if(!Board.getBlock(ahead).shape.equals(Shape.free) &&
				  !Board.getBlock(ahead).shape.equals(Shape.shelf)) {
			  return true;
		  }
		  return false;
	}
	
	protected boolean rampAhead() {
		  Point ahead = aheadPosition();
		  return Board.getBlock(ahead).shape.equals(Shape.ramp);
	}
	
	protected boolean shelfAhead() {
		  Point ahead = aheadPosition();
		  return Board.getBlock(ahead).shape.equals(Shape.shelf);
	}
	
	protected Color colorAhead() {
		  Point ahead = aheadPosition();
		  return Board.getBlock(ahead).color;
	}
	
	/* Check if the cell ahead is a wall */
	protected boolean isWall() {
		Point ahead = aheadPosition();
		return ahead.x<0 || ahead.y<0 || ahead.x>=Board.nX || ahead.y>=Board.nY;
	}
	
	protected boolean carryingBox() {
		return true;
	}

	/**********************/
	/**** C: actuators ****/
	/**********************/

	/* Rotate agent to right */
	public void rotate() {
		direction = (direction+90)%360;
	}
	
	/* Move agent forward */
	public void moveAhead() {
		Point ahead = aheadPosition();
		Board.updateEntityPosition(point,ahead);
		point = ahead;
	}
	
	
	/**********************/
	/**** D: auxiliary ****/
	/**********************/

	/* Position ahead */
	private Point aheadPosition() {
		Point newpoint = new Point(point.x,point.y);
		switch(direction) {
			case 0: newpoint.y++; break;
			case 90: newpoint.x++; break;
			case 180: newpoint.y--; break;
			default: newpoint.x--; 
		}
		return newpoint;
	}
}
