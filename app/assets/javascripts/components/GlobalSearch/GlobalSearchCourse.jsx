class GlobalSearchCourse extends React.Component {
    constructor(props) {
        super(props);
    }

    renderPoster() {
        let poster = this.props.course.poster;

        if (poster)
            return (
                <div className="col-md-4">
                    <img src={poster}/>
                </div>
            );
        else
            return null;
    }

    render() {
        let course = this.props.course;
        return (
            <a href={`/courses/${course.slug}`}
               className="round-0 list-group-item list-group-item-action flex-column align-items-start">
                <div className="row align-items-center">
                    {this.renderPoster()}
                    <div className="col">
                        <h5 className="mb-1">{course.title}</h5>
                        <small>{moment(course.updated_at).format('LLL')}</small>
                        <p className="mb-1">{course.description}</p>
                    </div>
                </div>
            </a>
        )
    }
}

GlobalSearchCourse.propTypes = {
    course: React.PropTypes.object
};